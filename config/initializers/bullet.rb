# frozen_string_literal: true

# Bullet - N+1 Query Detection
# https://github.com/flyerhzm/bullet

if defined?(Bullet)
  Bullet.enable = true

  # Enable alerts in development
  Bullet.alert = Rails.env.development?

  # Log to bullet.log
  Bullet.bullet_logger = true

  # Show warnings in browser console
  Bullet.console = Rails.env.development?

  # Add warnings to Rails log
  Bullet.rails_logger = true

  # Raise errors in test environment (strict mode)
  Bullet.raise = Rails.env.test?

  # Monitor these types of queries
  Bullet.add_footer = Rails.env.development? # Add footer with bullet warnings

  # Whitelist specific queries if needed (add as you encounter false positives)
  # Bullet.add_allowlist type: :n_plus_one_query, class_name: "Character", association: :guild
end
