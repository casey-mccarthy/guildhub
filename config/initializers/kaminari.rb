# frozen_string_literal: true

# Kaminari - Pagination
# https://github.com/kaminari/kaminari

Kaminari.configure do |config|
  # Default items per page
  config.default_per_page = 25

  # Maximum items per page
  config.max_per_page = 100

  # Maximum number of pagination links to show
  # config.max_pages = nil

  # Outer window for pagination links
  # config.outer_window = 0

  # Inner window for pagination links
  # config.left = 0
  # config.right = 0

  # Page method name
  # config.page_method_name = :page

  # Parameter name for page
  config.param_name = :page

  # Number of pagination links on each side of current page
  # config.window = 4
end
