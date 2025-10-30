# frozen_string_literal: true

# User model for GuildHub authentication
#
# Supports TWO authentication methods (easy to swap via configuration):
# 1. **Username/Password** (current, for local development)
# 2. **OAuth** (future, for production with Discord/Google/etc.)
#
# Fields:
# - email: Required for all auth methods
# - username: Optional display name
# - encrypted_password: For password auth (nullable for OAuth users)
# - provider/uid: For OAuth auth (nullable for password users)
# - avatar_url: OAuth provider's avatar (nullable)
# - admin: Admin privileges flag
#
# To swap to OAuth:
# 1. Add OmniAuth configuration (config/initializers/devise.rb)
# 2. Update routes to use omniauth_callbacks
# 3. Add from_omniauth class method (see comments below)
# 4. NO MIGRATION NEEDED - schema already supports both!
#
class User < ApplicationRecord
  # Devise modules for password authentication
  # Remove :database_authenticatable when swapping to OAuth-only
  # Note: :recoverable and :rememberable removed until we add those columns
  devise :database_authenticatable, :registerable,
         :validatable, :trackable

  # Validations
  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :username, uniqueness: { case_sensitive: false }, allow_nil: true
  validates :encrypted_password, presence: true, if: :password_auth?

  # For OAuth: provider and uid must be unique together
  validates :uid, uniqueness: { scope: :provider }, if: :oauth_auth?

  # Callbacks
  before_validation :normalize_email
  before_validation :set_default_username, if: :new_record?

  # Scopes
  scope :admins, -> { where(admin: true) }
  scope :members, -> { where(admin: false) }
  scope :password_users, -> { where(provider: nil) }
  scope :oauth_users, -> { where.not(provider: nil) }

  # Class methods for OAuth (uncomment when ready to swap)
  # def self.from_omniauth(auth_hash)
  #   where(provider: auth_hash['provider'], uid: auth_hash['uid']).first_or_create do |user|
  #     user.email = auth_hash['info']['email']
  #     user.username = auth_hash['info']['name'] || auth_hash['info']['nickname']
  #     user.avatar_url = auth_hash['info']['image']
  #     # No password needed for OAuth users
  #   end
  # end

  # Instance methods
  def display_name
    username.presence || email.split("@").first.presence || "User ##{id}"
  end

  def password_auth?
    provider.nil?
  end

  def oauth_auth?
    provider.present?
  end

  def admin?
    admin
  end

  # Override Devise's password_required? to allow OAuth users without passwords
  def password_required?
    password_auth? && (encrypted_password.blank? || password.present?)
  end

  private

  def normalize_email
    self.email = email.to_s.downcase.strip if email.present?
  end

  def set_default_username
    self.username ||= email.split("@").first if email.present?
  end
end
