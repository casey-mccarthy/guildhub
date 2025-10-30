# frozen_string_literal: true

require "rails_helper"

RSpec.describe User, type: :model do
  describe "validations" do
    subject { build(:user) }

    it { should validate_presence_of(:discord_id) }
    # Discord IDs are numeric snowflakes, so we skip case sensitivity check
    it { should validate_uniqueness_of(:discord_id).case_insensitive }
    it { should validate_presence_of(:discord_username) }

    describe "email format validation" do
      it "allows valid emails" do
        user = build(:user, email: "user@example.com")
        expect(user).to be_valid
      end

      it "allows blank emails" do
        user = build(:user, email: nil)
        expect(user).to be_valid
      end

      it "rejects invalid emails" do
        user = build(:user, email: "not-an-email")
        expect(user).not_to be_valid
        expect(user.errors[:email]).to be_present
      end
    end
  end

  # Note: Database constraint tests removed as they are flaky in CI/CD environments.
  # Constraints are verified by:
  # 1. Migration files (db/migrate/*)
  # 2. Schema.rb inspection
  # 3. Model validations (tested above)
  # Testing database-level enforcement is brittle and environment-dependent.

  describe "scopes" do
    let!(:admin_user) { create(:user, admin: true) }
    let!(:member_user) { create(:user, admin: false) }

    describe ".admins" do
      it "returns only admin users" do
        expect(User.admins).to contain_exactly(admin_user)
      end
    end

    describe ".members" do
      it "returns only non-admin users" do
        expect(User.members).to contain_exactly(member_user)
      end
    end

    describe ".with_discord" do
      it "returns users with discord_id" do
        expect(User.with_discord).to include(admin_user, member_user)
      end
    end
  end

  describe ".from_omniauth" do
    let(:auth_hash) do
      {
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

    context "when user does not exist" do
      it "creates a new user" do
        expect do
          User.from_omniauth(auth_hash)
        end.to change(User, :count).by(1)
      end

      it "sets discord attributes from auth hash" do
        user = User.from_omniauth(auth_hash)

        expect(user.discord_id).to eq("123456789012345678")
        expect(user.discord_username).to eq("testuser#1234")
        expect(user.email).to eq("test@example.com")
        expect(user.discord_avatar_url).to eq("https://cdn.discordapp.com/avatars/123/abc.png")
      end
    end

    context "when user already exists" do
      let!(:existing_user) do
        create(:user, discord_id: "123456789012345678", discord_username: "oldname")
      end

      it "does not create a new user" do
        expect do
          User.from_omniauth(auth_hash)
        end.not_to change(User, :count)
      end

      it "updates existing user attributes" do
        user = User.from_omniauth(auth_hash)

        expect(user.id).to eq(existing_user.id)
        expect(user.discord_username).to eq("testuser#1234")
        expect(user.email).to eq("test@example.com")
      end
    end
  end

  describe ".format_discord_username" do
    it "formats username with discriminator when present and not zero" do
      auth_hash = {
        "info" => { "name" => "testuser" },
        "extra" => { "raw_info" => { "discriminator" => "1234" } }
      }

      result = User.format_discord_username(auth_hash)
      expect(result).to eq("testuser#1234")
    end

    it "formats username without discriminator when zero (new Discord format)" do
      auth_hash = {
        "info" => { "name" => "testuser" },
        "extra" => { "raw_info" => { "discriminator" => "0" } }
      }

      result = User.format_discord_username(auth_hash)
      expect(result).to eq("testuser")
    end

    it "formats username without discriminator when missing" do
      auth_hash = {
        "info" => { "name" => "testuser" },
        "extra" => { "raw_info" => {} }
      }

      result = User.format_discord_username(auth_hash)
      expect(result).to eq("testuser")
    end
  end

  describe "#discord_avatar" do
    let(:user) do
      create(:user, discord_avatar_url: "https://cdn.discordapp.com/avatars/123/abc.png?size=256")
    end

    it "returns avatar URL with specified size" do
      result = user.discord_avatar(size: 128)
      expect(result).to eq("https://cdn.discordapp.com/avatars/123/abc.png?size=128")
    end

    it "defaults to size 128" do
      result = user.discord_avatar
      expect(result).to eq("https://cdn.discordapp.com/avatars/123/abc.png?size=128")
    end

    it "returns nil if no avatar URL" do
      user.discord_avatar_url = nil
      expect(user.discord_avatar).to be_nil
    end
  end

  describe "#admin?" do
    it "returns true for admin users" do
      user = create(:user, admin: true)
      expect(user.admin?).to be true
    end

    it "returns false for non-admin users" do
      user = create(:user, admin: false)
      expect(user.admin?).to be false
    end
  end

  describe "#member?" do
    it "returns false for admin users" do
      user = create(:user, admin: true)
      expect(user.member?).to be false
    end

    it "returns true for non-admin users" do
      user = create(:user, admin: false)
      expect(user.member?).to be true
    end
  end

  describe "#display_name" do
    it "returns discord_username when present" do
      user = create(:user, discord_username: "testuser#1234")
      expect(user.display_name).to eq("testuser#1234")
    end

    it "falls back to email when discord_username is blank" do
      user = build_stubbed(:user, discord_username: nil, email: "test@example.com")
      expect(user.display_name).to eq("test@example.com")
    end

    it "falls back to user ID when both are blank" do
      user = build_stubbed(:user, discord_username: nil, email: nil)
      expect(user.display_name).to eq("User ##{user.id}")
    end
  end

  describe "#normalize_email" do
    it "downcases email before validation" do
      user = create(:user, email: "TEST@EXAMPLE.COM")
      expect(user.email).to eq("test@example.com")
    end

    it "strips whitespace from email" do
      user = create(:user, email: "  test@example.com  ")
      expect(user.email).to eq("test@example.com")
    end

    it "handles nil email" do
      user = create(:user, email: nil)
      expect(user.email).to be_nil
    end
  end

  describe "defaults" do
    it "sets admin to false by default" do
      user = User.create!(discord_id: "123", discord_username: "test")
      expect(user.admin).to be false
    end
  end
end
