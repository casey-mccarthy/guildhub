class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Devise authentication
  before_action :authenticate_user!, unless: :devise_controller?

  # Make current_user and authentication helpers available in views
  helper_method :current_user, :user_signed_in?

  # Customize Devise redirect after sign in
  def after_sign_in_path_for(resource)
    stored_location_for(resource) || root_path
  end

  # Customize Devise redirect after sign out
  def after_sign_out_path_for(resource_or_scope)
    root_path
  end
end
