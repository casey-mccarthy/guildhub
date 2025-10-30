# frozen_string_literal: true

require "bcrypt"

FactoryBot.define do
  factory :user do
    # Discord ID is a snowflake (18-19 digit number)
    sequence(:discord_id) { |n| "#{1234567890123456700 + n}" }

    # Discord username (with optional discriminator)
    discord_username { "#{Faker::Internet.username}##{rand(1000..9999)}" }

    # Discord avatar URL (CDN format)
    discord_avatar_url do
      "https://cdn.discordapp.com/avatars/#{discord_id}/#{Faker::Alphanumeric.alpha(number: 32)}.png?size=128"
    end

    # Email from Discord
    email { Faker::Internet.email }

    # Not used for Discord OAuth users, only for admin Devise authentication
    encrypted_password { nil }

    # Default to non-admin
    admin { false }

    # Traits for different user types
    trait :admin do
      admin { true }
      encrypted_password { BCrypt::Password.create("password123", cost: 4) }
    end

    trait :member do
      admin { false }
    end

    trait :without_email do
      email { nil }
    end

    trait :without_avatar do
      discord_avatar_url { nil }
    end

    # Factory for creating admin users
    factory :admin_user, traits: [ :admin ]

    # Factory for creating member users
    factory :member_user, traits: [ :member ]
  end
end
