# frozen_string_literal: true

module Auth
  # Handles OmniAuth callbacks for Discord OAuth authentication
  #
  # This controller receives the OAuth callback from Discord after user authorization.
  # It creates or updates the user record and establishes a session.
  #
  # Routes:
  # - GET /auth/discord/callback (success)
  # - GET /auth/failure (failure)
  #
  # Epic 2 - Task T2.1.4: Implement OmniAuth callback controller

  class CallbacksController < ApplicationController
    # Skip CSRF protection for OAuth callbacks (handled by omniauth-rails_csrf_protection)
    skip_before_action :verify_authenticity_token, only: [ :create, :failure ]

    # Handle successful OAuth callback
    # GET /auth/:provider/callback
    def create
      auth_hash = request.env["omniauth.auth"]

      if auth_hash.blank?
        redirect_to root_path, alert: "Authentication failed: No data received from Discord."
        return
      end

      begin
        @user = User.from_omniauth(auth_hash)

        if @user.persisted?
          # Set user session
          session[:user_id] = @user.id

          # Log successful authentication
          Rails.logger.info "User authenticated via Discord: #{@user.discord_username} (ID: #{@user.id})"

          # Redirect to dashboard or return URL
          redirect_to after_sign_in_path, notice: "Successfully signed in with Discord!"
        else
          # User creation failed
          Rails.logger.error "Failed to create user from Discord OAuth: #{@user.errors.full_messages.join(', ')}"
          redirect_to root_path, alert: "Failed to create account. Please try again."
        end
      rescue StandardError => e
        # Handle any unexpected errors
        Rails.logger.error "OAuth callback error: #{e.class} - #{e.message}"
        Rails.logger.error e.backtrace.join("\n")

        redirect_to root_path, alert: "An error occurred during sign in. Please try again."
      end
    end

    # Handle OAuth failure
    # GET /auth/failure
    def failure
      error_type = params[:message] || "unknown_error"
      error_message = params[:error_description] || "Authentication failed"

      Rails.logger.error "OAuth failure: #{error_type} - #{error_message}"

      redirect_to root_path, alert: "Discord authentication failed: #{error_type.humanize}"
    end

    private

    # Determine where to redirect after successful sign in
    def after_sign_in_path
      # Return to stored location or default to root
      # In T3.3.3, this will redirect to "My Characters" dashboard
      stored_location = session.delete(:return_to)
      stored_location || root_path
    end
  end
end
