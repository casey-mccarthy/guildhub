# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Discord Authentication", type: :system do
  before do
    driven_by(:rack_test)
  end

  describe "Login with Discord" do
    context "when user is not signed in" do
      it "shows the login button" do
        visit root_path

        expect(page).to have_link("Login with Discord", href: "/auth/discord")
      end

      it "shows the Discord logo" do
        visit root_path

        expect(page).to have_css("svg", visible: true)
      end

      it "shows helper text" do
        visit root_path

        expect(page).to have_content("Sign in with your Discord account to get started")
      end

      it "does not show user info" do
        visit root_path

        expect(page).not_to have_button("Logout")
      end
    end

    context "when user is signed in" do
      let(:user) { create(:user, discord_username: "testuser#1234") }

      before do
        # Simulate signed-in user by setting session
        page.set_rack_session(user_id: user.id)
      end

      it "does not show login button" do
        visit root_path

        expect(page).not_to have_link("Login with Discord")
      end

      it "shows user display name" do
        visit root_path

        expect(page).to have_content("testuser#1234")
      end

      it "shows user avatar when present" do
        user.update(discord_avatar_url: "https://cdn.discordapp.com/avatars/123/abc.png")

        visit root_path

        expect(page).to have_css("img[alt='testuser#1234']")
      end

      it "shows avatar placeholder when avatar is missing" do
        user.update(discord_avatar_url: nil)

        visit root_path

        # Should show first letter of username
        expect(page).to have_content("T") # First letter of "testuser"
      end

      it "shows logout button" do
        visit root_path

        expect(page).to have_button("Logout")
      end

      it "shows admin badge for admin users" do
        user.update(admin: true)

        visit root_path

        expect(page).to have_content("ADMIN")
      end

      it "does not show admin badge for regular users" do
        user.update(admin: false)

        visit root_path

        expect(page).not_to have_content("ADMIN")
      end
    end
  end

  describe "Logout" do
    let(:user) { create(:user) }

    before do
      page.set_rack_session(user_id: user.id)
    end

    it "logs out user when clicking logout button" do
      visit root_path

      click_button "Logout"

      expect(page).to have_content("Successfully signed out")
      expect(page).to have_link("Login with Discord")
    end
  end

  describe "OAuth Flow" do
    before do
      OmniAuth.config.test_mode = true
      OmniAuth.config.mock_auth[:discord] = OmniAuth::AuthHash.new({
        "provider" => "discord",
        "uid" => "123456789012345678",
        "info" => {
          "name" => "newuser",
          "email" => "newuser@example.com",
          "image" => "https://cdn.discordapp.com/avatars/123/def.png"
        },
        "extra" => {
          "raw_info" => {
            "discriminator" => "5678"
          }
        }
      })
    end

    after do
      OmniAuth.config.test_mode = false
    end

    it "creates user and logs in via Discord OAuth" do
      visit root_path

      expect do
        click_link "Login with Discord"
      end.to change(User, :count).by(1)

      expect(page).to have_content("Successfully signed in with Discord")
      expect(page).to have_content("newuser#5678")
    end
  end
end
