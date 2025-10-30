# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Sessions", type: :request do
  describe "DELETE /logout" do
    context "when user is signed in" do
      let(:user) { create(:user) }

      before do
        # Simulate signed-in user by setting session
        # In Rails 8, we need to set session separately
        get root_path # Initialize session
        session[:user_id] = user.id
      end

      it "clears the session" do
        delete logout_path

        expect(session[:user_id]).to be_nil
      end

      it "redirects to root path" do
        delete logout_path

        expect(response).to redirect_to(root_path)
      end

      it "shows success notice" do
        delete logout_path

        follow_redirect!
        expect(response.body).to include("Successfully signed out")
      end

      it "logs the logout" do
        expect(Rails.logger).to receive(:info).with(/User logged out:/)

        delete logout_path
      end
    end

    context "when user is not signed in" do
      it "redirects to root path" do
        delete logout_path

        expect(response).to redirect_to(root_path)
      end

      it "shows success notice anyway" do
        delete logout_path

        follow_redirect!
        expect(response.body).to include("Successfully signed out")
      end
    end
  end
end
