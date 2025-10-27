# frozen_string_literal: true

# Handles user session management (logout)
#
# Login is handled by Auth::CallbacksController via Discord OAuth.
# This controller only handles logout.
#
# Epic 2 - Task T2.2.2: Create logout functionality

class SessionsController < ApplicationController
  # Logout - destroy user session
  # DELETE /logout
  def destroy
    if current_user
      username = current_user.discord_username
      Rails.logger.info "User logged out: #{username} (ID: #{current_user.id})"
    end

    # Clear session
    reset_session

    redirect_to root_path, notice: "Successfully signed out."
  end
end
