# GuildHub - Gem Reference

This document lists all non-standard gems used in GuildHub and their purpose.

## Authentication & Authorization

### Devise (~> 4.9)
- **Purpose:** Admin panel authentication with email/password
- **Usage:** Admin dashboard login (Phase 2)
- **Docs:** https://github.com/heartcombo/devise

### OmniAuth Discord
- **Purpose:** Discord OAuth integration for primary user authentication
- **Usage:** User login via Discord (Phase 2)
- **Docs:** https://github.com/adaoraul/omniauth-discord

### OmniAuth Rails CSRF Protection
- **Purpose:** CSRF protection for OmniAuth authentication
- **Usage:** Security for OAuth flows
- **Docs:** https://github.com/cookpad/omniauth-rails_csrf_protection

### Pundit (~> 2.3)
- **Purpose:** Authorization/policy-based access control
- **Usage:** Define who can view/edit guilds, characters, raids, etc.
- **Docs:** https://github.com/varvet/pundit

## Data Management

### PaperTrail (~> 15.0)
- **Purpose:** Audit trail and versioning
- **Usage:** Track changes to DKP adjustments, loot awards, raid attendance
- **Docs:** https://github.com/paper-trail-gem/paper_trail

### Kaminari (~> 1.2)
- **Purpose:** Pagination
- **Usage:** Paginate character lists, raid history, loot awards
- **Docs:** https://github.com/kaminari/kaminari
- **Config:** `config/initializers/kaminari.rb` (25 items/page default)

### PgSearch (~> 2.3)
- **Purpose:** PostgreSQL full-text search
- **Usage:** Search characters, items, raids
- **Docs:** https://github.com/Casecommons/pg_search

## API & Serialization

### JSONAPI::Serializer
- **Purpose:** Fast JSON API serialization
- **Usage:** API endpoints for Discord bot integration (Phase 7)
- **Docs:** https://github.com/jsonapi-serializer/jsonapi-serializer

## UI Components

### ViewComponent (~> 3.0)
- **Purpose:** Reusable, testable view components
- **Usage:** Character cards, DKP displays, raid summaries
- **Docs:** https://viewcomponent.org/

## Development Tools

### Pry Rails
- **Purpose:** Enhanced Rails console with debugging features
- **Usage:** `rails console` - use `binding.pry` for breakpoints
- **Docs:** https://github.com/pry/pry-rails

### Bullet
- **Purpose:** N+1 query detection
- **Usage:** Automatically alerts on N+1 queries in development
- **Config:** `config/initializers/bullet.rb`
- **Docs:** https://github.com/flyerhzm/bullet

### Rack Mini Profiler
- **Purpose:** Performance profiling
- **Usage:** Shows page load times, SQL queries, memory usage
- **Docs:** https://github.com/MiniProfiler/rack-mini-profiler
- **UI:** Top-left corner badge in development

### Letter Opener
- **Purpose:** Email preview in browser
- **Usage:** Emails open in browser instead of being sent
- **Config:** `config/environments/development.rb`
- **Docs:** https://github.com/ryanb/letter_opener

## Testing (See CLAUDE.md for usage)

- RSpec Rails
- FactoryBot
- Faker
- Capybara
- Selenium WebDriver
- SimpleCov
- Shoulda Matchers
- Database Cleaner

## Code Quality

- Rubocop Rails Omakase (style guide)
- Brakeman (security scanner)

## Core Rails 8 Gems (Built-in)

- **Solid Queue** - Background jobs (replaces Sidekiq)
- **Solid Cache** - Database-backed caching
- **Solid Cable** - WebSocket connections
- **Propshaft** - Asset pipeline (replaces Sprockets)
- **Turbo Rails** - SPA-like navigation
- **Stimulus Rails** - JavaScript framework

## Future Gems (Not Yet Installed)

These will be added as needed in later phases:

- **Discordrb** - Discord bot (Epic 10)
- **ActiveStorage Validators** - File upload validation
- **Pagy** - Alternative pagination (if Kaminari doesn't fit needs)

## Gem Update Policy

- **Security updates:** Apply immediately
- **Minor updates:** Review changelog, apply quarterly
- **Major updates:** Plan carefully, review breaking changes
- **Dependabot:** Enabled for automated PR creation

## Useful Commands

```bash
# List all gems
bundle list

# Show gem info
bundle info devise

# Check for outdated gems
bundle outdated

# Update specific gem
bundle update devise

# Update all gems (use with caution)
bundle update

# Audit for security vulnerabilities
bundle exec bundle-audit
```

---

**Last Updated:** October 23, 2024
**Phase:** Epic 1 - Infrastructure Setup
