# frozen_string_literal: true

# OmniAuth Configuration for Discord OAuth
#
# This initializer sets up Discord OAuth authentication for GuildHub.
# Users can login using their Discord account ("Login with Discord").
#
# Setup: Follow docs/DISCORD_SETUP.md to configure Discord application
# Credentials: Stored in Rails encrypted credentials (bin/rails credentials:edit)
#
# Epic 2 - Task T2.1.2: Configure OmniAuth Discord

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :discord,
    Rails.application.credentials.dig(:discord, :client_id),
    Rails.application.credentials.dig(:discord, :client_secret),
    scope: "identify email",
    callback_path: "/auth/discord/callback"
end

# Configure OmniAuth settings
OmniAuth.config.allowed_request_methods = [ :get, :post ]
OmniAuth.config.silence_get_warning = true

# In production, always use HTTPS for OAuth callbacks
if Rails.env.production?
  OmniAuth.config.full_host = ENV["OAUTH_FULL_HOST"] || "https://guildhub.com"
end

# Configure failure handling
OmniAuth.config.on_failure = proc { |env|
  message_key = env["omniauth.error.type"]
  error_type = message_key.to_s.humanize if message_key

  Rails.logger.error "OmniAuth failure: #{error_type} - #{env['omniauth.error']}"

  # Redirect to login page with error message
  Rack::Response.new(
    [ "Authentication failed: #{error_type}" ],
    302,
    { "Location" => "/?auth_error=#{error_type}" }
  ).finish
}

# Log OmniAuth activity in development
if Rails.env.development?
  OmniAuth.config.logger = Rails.logger
end
