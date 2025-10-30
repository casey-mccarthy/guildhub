# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Auth::Callbacks", type: :request do
  describe "GET /auth/discord/callback" do
    let(:auth_hash) do
      {
        "provider" => "discord",
        "uid" => "123456789012345678",
        "info" => {
          "name" => "testuser",
          "email" => "test@example.com",
          "image" => "https://cdn.discordapp.com/avatars/123/abc.png"
        },
        "extra" => {
          "raw_info" => {
            "discriminator" => "1234"
          }
        }
      }
    end

    before do
      # Mock OmniAuth to return our test auth hash
      OmniAuth.config.test_mode = true
      OmniAuth.config.mock_auth[:discord] = OmniAuth::AuthHash.new(auth_hash)
    end

    after do
      OmniAuth.config.test_mode = false
    end

    context "when user does not exist" do
      it "creates a new user" do
        expect do
          get auth_callback_path(provider: "discord")
        end.to change(User, :count).by(1)
      end

      it "sets the user session" do
        get auth_callback_path(provider: "discord")

        expect(session[:user_id]).to be_present
        expect(session[:user_id]).to eq(User.last.id)
      end

      it "redirects to root path" do
        get auth_callback_path(provider: "discord")

        expect(response).to redirect_to(root_path)
      end

      it "shows success notice" do
        get auth_callback_path(provider: "discord")

        follow_redirect!
        expect(response.body).to include("Successfully signed in with Discord")
      end

      it "logs the authentication" do
        expect(Rails.logger).to receive(:info).with(/User authenticated via Discord/)

        get auth_callback_path(provider: "discord")
      end
    end

    context "when user already exists" do
      let!(:existing_user) do
        create(:user, discord_id: "123456789012345678", discord_username: "oldname")
      end

      it "does not create a new user" do
        expect do
          get auth_callback_path(provider: "discord")
        end.not_to change(User, :count)
      end

      it "updates the existing user" do
        get auth_callback_path(provider: "discord")

        existing_user.reload
        expect(existing_user.discord_username).to eq("testuser#1234")
        expect(existing_user.email).to eq("test@example.com")
      end

      it "sets the session to existing user" do
        get auth_callback_path(provider: "discord")

        expect(session[:user_id]).to eq(existing_user.id)
      end

      it "redirects to root path" do
        get auth_callback_path(provider: "discord")

        expect(response).to redirect_to(root_path)
      end
    end

    context "when return_to is stored in session" do
      it "redirects to stored location after sign in" do
        # Simulate authenticate_user! storing return path
        # In Rails 8, we need to set session in a separate step
        # First, make a request to set the session, then test the callback
        get root_path # Initialize session
        session[:return_to] = "/characters" # Set return path

        get auth_callback_path(provider: "discord")

        expect(response).to redirect_to("/characters")
      end

      it "clears return_to from session" do
        get root_path # Initialize session
        session[:return_to] = "/characters" # Set return path

        get auth_callback_path(provider: "discord")

        expect(session[:return_to]).to be_nil
      end
    end

    context "when auth hash is missing" do
      before do
        allow_any_instance_of(Auth::CallbacksController).to receive_message_chain(:request, :env).and_return({})
      end

      it "redirects to root with error" do
        get auth_callback_path(provider: "discord")

        expect(response).to redirect_to(root_path)
      end

      it "shows error message" do
        get auth_callback_path(provider: "discord")

        follow_redirect!
        expect(response.body).to include("Authentication failed")
      end
    end

    context "when user creation fails" do
      before do
        allow(User).to receive(:from_omniauth).and_return(User.new)
      end

      it "redirects to root with error" do
        get auth_callback_path(provider: "discord")

        expect(response).to redirect_to(root_path)
      end

      it "shows error message" do
        get auth_callback_path(provider: "discord")

        follow_redirect!
        expect(response.body).to include("Failed to create account")
      end

      it "logs the error" do
        expect(Rails.logger).to receive(:error).with(/Failed to create user from Discord OAuth/)

        get auth_callback_path(provider: "discord")
      end
    end

    context "when an exception occurs" do
      before do
        allow(User).to receive(:from_omniauth).and_raise(StandardError, "Test error")
      end

      it "redirects to root with error" do
        get auth_callback_path(provider: "discord")

        expect(response).to redirect_to(root_path)
      end

      it "shows generic error message" do
        get auth_callback_path(provider: "discord")

        follow_redirect!
        expect(response.body).to include("An error occurred during sign in")
      end

      it "logs the exception" do
        expect(Rails.logger).to receive(:error).with(/OAuth callback error: StandardError - Test error/)

        get auth_callback_path(provider: "discord")
      end
    end
  end

  describe "GET /auth/failure" do
    it "redirects to root path" do
      get auth_failure_path

      expect(response).to redirect_to(root_path)
    end

    it "shows error message with failure type" do
      get auth_failure_path, params: { message: "access_denied" }

      follow_redirect!
      expect(response.body).to include("Discord authentication failed")
      expect(response.body).to include("Access denied")
    end

    it "logs the OAuth failure" do
      expect(Rails.logger).to receive(:error).with(/OAuth failure: access_denied/)

      get auth_failure_path, params: { message: "access_denied", error_description: "User denied" }
    end

    it "handles unknown error gracefully" do
      get auth_failure_path

      follow_redirect!
      expect(response.body).to include("Unknown error")
    end
  end
end
