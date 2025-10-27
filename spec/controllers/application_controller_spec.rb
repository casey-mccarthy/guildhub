# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApplicationController, type: :controller do
  controller do
    def index
      render plain: "OK"
    end

    def protected_action
      authenticate_user!
      render plain: "Protected"
    end

    def admin_action
      authenticate_admin!
      render plain: "Admin"
    end
  end

  before do
    routes.draw do
      get "index" => "anonymous#index"
      get "protected_action" => "anonymous#protected_action"
      get "admin_action" => "anonymous#admin_action"
    end
  end

  describe "#current_user" do
    context "when user is signed in" do
      let(:user) { create(:user) }

      before do
        session[:user_id] = user.id
      end

      it "returns the current user" do
        get :index

        expect(controller.send(:current_user)).to eq(user)
      end

      it "memoizes the user query" do
        get :index

        expect(User).to receive(:find_by).once.and_return(user)

        controller.send(:current_user)
        controller.send(:current_user)
      end
    end

    context "when user is not signed in" do
      it "returns nil" do
        get :index

        expect(controller.send(:current_user)).to be_nil
      end
    end

    context "when session user_id is invalid" do
      before do
        session[:user_id] = 99999
      end

      it "returns nil" do
        get :index

        expect(controller.send(:current_user)).to be_nil
      end
    end
  end

  describe "#user_signed_in?" do
    context "when user is signed in" do
      let(:user) { create(:user) }

      before do
        session[:user_id] = user.id
      end

      it "returns true" do
        get :index

        expect(controller.send(:user_signed_in?)).to be true
      end
    end

    context "when user is not signed in" do
      it "returns false" do
        get :index

        expect(controller.send(:user_signed_in?)).to be false
      end
    end
  end

  describe "#authenticate_user!" do
    context "when user is signed in" do
      let(:user) { create(:user) }

      before do
        session[:user_id] = user.id
      end

      it "allows access" do
        get :protected_action

        expect(response.body).to eq("Protected")
      end

      it "does not redirect" do
        get :protected_action

        expect(response).to have_http_status(:ok)
      end
    end

    context "when user is not signed in" do
      it "redirects to root path" do
        get :protected_action

        expect(response).to redirect_to(root_path)
      end

      it "shows alert message" do
        get :protected_action

        follow_redirect!
        expect(response.body).to include("Please sign in to continue")
      end

      it "stores return path in session" do
        get :protected_action

        expect(session[:return_to]).to eq("/protected_action")
      end

      it "does not store root path as return path" do
        routes.draw do
          root to: "anonymous#protected_action"
        end

        get :protected_action

        expect(session[:return_to]).to be_nil
      end
    end
  end

  describe "#authenticate_admin!" do
    context "when user is admin" do
      let(:admin) { create(:user, :admin) }

      before do
        session[:user_id] = admin.id
      end

      it "allows access" do
        get :admin_action

        expect(response.body).to eq("Admin")
      end
    end

    context "when user is not admin" do
      let(:user) { create(:user, admin: false) }

      before do
        session[:user_id] = user.id
      end

      it "redirects to root path" do
        get :admin_action

        expect(response).to redirect_to(root_path)
      end

      it "shows unauthorized message" do
        get :admin_action

        follow_redirect!
        expect(response.body).to include("You are not authorized")
      end
    end

    context "when user is not signed in" do
      it "redirects to root path" do
        get :admin_action

        expect(response).to redirect_to(root_path)
      end

      it "shows sign in message" do
        get :admin_action

        follow_redirect!
        expect(response.body).to include("Please sign in to continue")
      end
    end
  end
end
