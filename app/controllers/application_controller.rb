# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Make authentication helper methods available in views
  helper_method :current_user, :user_signed_in?

  private

  # Get the currently signed-in user
  # @return [User, nil] The current user or nil if not signed in
  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  # Check if a user is currently signed in
  # @return [Boolean] true if user is signed in
  def user_signed_in?
    current_user.present?
  end

  # Require user to be signed in
  # Redirects to root with alert if not authenticated
  # @return [Boolean] true if authenticated, false if redirected
  def authenticate_user!
    return true if user_signed_in?

    # Store the requested path to return after sign in
    session[:return_to] = request.fullpath unless request.fullpath == root_path

    redirect_to root_path, alert: "Please sign in to continue."
    false
  end

  # Require user to be an admin
  # Redirects to root with alert if not authorized
  # @return [Boolean] true if admin, false if redirected
  def authenticate_admin!
    return false unless authenticate_user!

    return true if current_user&.admin?

    redirect_to root_path, alert: "You are not authorized to access this page."
    false
  end
end
