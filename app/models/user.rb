# frozen_string_literal: true

# User model for GuildHub authentication
#
# Users authenticate via Discord OAuth (primary method) or email/password (admin panel).
#
# Discord OAuth fields:
# - discord_id: Unique Discord user ID (snowflake)
# - discord_username: Discord username (e.g., "username#1234")
# - discord_avatar_url: URL to Discord avatar image
# - email: Discord-provided email
#
# Admin authentication:
# - encrypted_password: For Devise email/password login (admin panel)
# - admin: Boolean flag for admin privileges
#
# Epic 2 - Task T2.1.3: Create Users migration and model

class User < ApplicationRecord
  # Validations
  validates :discord_id, presence: true, uniqueness: { case_sensitive: false }
  validates :discord_username, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP, allow_blank: true }

  # Associations
  # has_many :characters, dependent: :nullify (T3.2.4)
  # has_many :announcements, dependent: :destroy (T8.1.1)

  # Callbacks
  before_validation :normalize_email

  # Scopes
  scope :admins, -> { where(admin: true) }
  scope :members, -> { where(admin: false) }
  scope :with_discord, -> { where.not(discord_id: nil) }

  # Class methods
  def self.from_omniauth(auth_hash)
    # Find or create user from Discord OAuth response
    # Called from Auth::CallbacksController (T2.1.4)
    where(discord_id: auth_hash["uid"]).first_or_initialize.tap do |user|
      user.discord_username = format_discord_username(auth_hash)
      user.discord_avatar_url = auth_hash.dig("info", "image")
      user.email = auth_hash.dig("info", "email")
      user.save!
    end
  end

  def self.format_discord_username(auth_hash)
    # Discord usernames can be in format "username" or "username#1234"
    username = auth_hash.dig("info", "name")
    discriminator = auth_hash.dig("extra", "raw_info", "discriminator")

    if discriminator && discriminator != "0"
      "#{username}##{discriminator}"
    else
      username
    end
  end

  # Instance methods
  def discord_avatar(size: 128)
    # Get Discord avatar URL with specific size
    # Sizes: 16, 32, 64, 128, 256, 512, 1024, 2048
    return nil unless discord_avatar_url

    # Discord CDN URLs support size parameter
    discord_avatar_url.gsub(/\?size=\d+/, "?size=#{size}")
  end

  def admin?
    admin == true
  end

  def member?
    !admin?
  end

  def display_name
    # Use Discord username, fallback to email or ID
    discord_username || email || "User ##{id}"
  end

  private

  def normalize_email
    self.email = email.downcase.strip if email.present?
  end
end
