# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Discord Credentials Configuration", type: :config do
  describe "credentials structure" do
    it "has discord configuration" do
      expect(Rails.application.credentials.discord).to be_present
    end

    it "has client_id configured" do
      expect(Rails.application.credentials.discord.client_id).to be_present
      expect(Rails.application.credentials.discord.client_id).to be_a(String)
    end

    it "has client_secret configured" do
      expect(Rails.application.credentials.discord.client_secret).to be_present
      expect(Rails.application.credentials.discord.client_secret).to be_a(String)
    end

    it "client_id is not a placeholder" do
      client_id = Rails.application.credentials.discord.client_id
      placeholder_values = %w[YOUR_CLIENT_ID_HERE REPLACE_ME CHANGEME]

      expect(placeholder_values).not_to include(client_id)
    end

    it "client_secret is not a placeholder" do
      client_secret = Rails.application.credentials.discord.client_secret
      placeholder_values = %w[YOUR_CLIENT_SECRET_HERE REPLACE_ME CHANGEME]

      expect(placeholder_values).not_to include(client_secret)
    end

    it "client_id has reasonable length" do
      client_id = Rails.application.credentials.discord.client_id
      # Discord Client IDs are typically 18-19 digits (snowflake IDs)
      expect(client_id.length).to be >= 17
    end

    it "client_secret has reasonable length" do
      client_secret = Rails.application.credentials.discord.client_secret
      # Discord Client Secrets are typically 32+ characters
      expect(client_secret.length).to be >= 30
    end
  end

  describe "optional bot configuration" do
    # Bot token is optional for now (Phase 3)
    it "allows bot_token to be nil (not required yet)" do
      bot_token = Rails.application.credentials.discord.bot_token
      # Can be present or nil - both are acceptable for OAuth-only setup
      expect([String, NilClass]).to include(bot_token.class)
    end
  end
end
