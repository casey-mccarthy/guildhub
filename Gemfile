source "https://rubygems.org"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.1.0"
# The modern asset pipeline for Rails [https://github.com/rails/propshaft]
gem "propshaft"
# Use postgresql as the database for Active Record
gem "pg", "~> 1.1"
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"
# Bundle and transpile JavaScript [https://github.com/rails/jsbundling-rails]
gem "jsbundling-rails"
# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"
# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"
# Bundle and process CSS [https://github.com/rails/cssbundling-rails]
gem "cssbundling-rails"
# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Use the database-backed adapters for Rails.cache, Active Job, and Action Cable
gem "solid_cache"
gem "solid_queue"
gem "solid_cable"

# Redis for caching and ActionCable
gem "redis", "~> 5.3"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Deploy this application anywhere as a Docker container [https://kamal-deploy.org]
gem "kamal", require: false

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem "thruster", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

# Authentication
gem "devise", "~> 4.9"
gem "omniauth-discord"
gem "omniauth-rails_csrf_protection"

# Authorization
gem "pundit", "~> 2.3"

# Audit trail
gem "paper_trail", "~> 17.0"

# Pagination
gem "kaminari", "~> 1.2"

# PostgreSQL full-text search
gem "pg_search", "~> 2.3"

# API serialization
gem "jsonapi-serializer"

# View components - temporarily disabled until Rails 8.1 support available
# gem "view_component", "~> 3.0"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "brakeman", require: false

  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem "rubocop-rails-omakase", require: false

  # Testing framework
  gem "rspec-rails", "~> 8.0"
  gem "factory_bot_rails", "~> 6.4"
  gem "faker", "~> 3.5"
end

group :test do
  # System testing
  gem "capybara", "~> 3.40"
  gem "selenium-webdriver"

  # Code coverage
  gem "simplecov", require: false

  # Test helpers
  gem "shoulda-matchers", "~> 6.4"
  gem "database_cleaner-active_record", "~> 2.2"

  # RSpec formatters
  gem "rspec_junit_formatter", "~> 0.6"
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"

  # Enhanced Rails console
  gem "pry-rails"

  # N+1 query detection
  gem "bullet"

  # Performance profiling
  gem "rack-mini-profiler"

  # Email preview in development
  gem "letter_opener"
end
