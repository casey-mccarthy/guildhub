# GuildHub Development Guide for Claude

This document provides context for AI assistants (Claude, etc.) working on the GuildHub Rails application.

## Project Overview

**GuildHub** is a modern Rails 8.x DKP (Dragon Kill Points) management system designed exclusively for **Project 1999 EverQuest guilds**. It replaces the archived EQdkpPlus PHP application with a modern, maintainable Ruby on Rails stack.

## Quick Reference

- **Language:** Ruby 3.3+
- **Framework:** Rails 8.0+
- **Database:** PostgreSQL 16+
- **Cache/Jobs:** Redis 7+ / Solid Queue
- **Frontend:** Hotwire (Turbo + Stimulus), Tailwind CSS 4.0+
- **Authentication:** Discord OAuth (OmniAuth) + Devise (admin panel)
- **Authorization:** Pundit
- **Testing:** RSpec, FactoryBot, Capybara

## Key Documentation

All planning documents are in the `/docs` directory:

- **`docs/PRD-GuildHub-RailsVersion.md`** - Product Requirements Document
- **`docs/ERD-GuildHub-P99.md`** - Complete database schema
- **`docs/ModernArchitecture.md`** - Technical architecture
- **`docs/ImplementationRoadmap.md`** - 8-month development timeline
- **`docs/TASKS.md`** - All 170+ implementation tasks
- **`docs/MigrationStrategy.md`** - EQdkpPlus migration approach

## GitHub Issues

All work is tracked in GitHub Issues:
- **Epic Issues:** #1-#14 (high-level features)
- **Task Issues:** #15-#191 (individual implementation tasks)
- **Milestones:** 4 phases mapped to 8-month timeline
- **Labels:** Epic, type, story points, priority, phase

## Project 1999 EverQuest Context

GuildHub is **exclusively** for P99 EverQuest guilds. Key P99-specific details:

### Classes (14)
Warrior, Cleric, Paladin, Ranger, Shadow Knight, Druid, Monk, Bard, Rogue, Shaman, Necromancer, Wizard, Magician, Enchanter

### Races (12)
Human, Barbarian, Erudite, Wood Elf, High Elf, Dark Elf, Half Elf, Dwarf, Troll, Ogre, Halfling, Gnome

### Servers
- **Blue:** Velious era
- **Green:** Kunark era

### Level Cap
1-60 (P99 classic EverQuest cap)

### Common Raid Targets
- Plane of Fear, Plane of Hate, Plane of Sky
- Lord Nagafen, Lady Vox
- Innoruuk, Cazic-Thule
- Dragons: Talendor, Severilous, Gorenaire, etc.

## Database Schema Highlights

### Core Models (10 tables)

1. **users** - Discord OAuth authentication + admin credentials
2. **guilds** - P99 guild with single DKP pool config (JSONB)
3. **characters** - EQ characters with P99 classes/races/levels
4. **events** - Raid event types with default point values
5. **raids** - Actual raid instances
6. **raid_attendances** - Who attended which raid (DKP earned)
7. **items** - Loot drops (stored as item_awards)
8. **item_awards** - Who won what item (DKP spent)
9. **dkp_adjustments** - Manual DKP modifications
10. **announcements** - Guild announcements with comments

### Key Design Decisions

**Single DKP Pool:**
- Stored in `guilds.dkp_config` JSONB field
- No multi-pool complexity (simplified from EQdkpPlus)

**Calculated DKP Balances:**
- NOT stored in database
- Calculated on-demand: `SUM(earned) - SUM(spent) + SUM(adjustments)`
- Cached in Redis for 5 minutes
- Invalidated on: attendance change, item award, adjustment

**Discord-First Authentication:**
- Users log in via Discord OAuth
- `users.discord_id` is the primary identifier
- Admin panel uses Devise (email/password) for officers

**No Calendar/Signups:**
- P99 guilds use Discord for raid scheduling
- GuildHub only tracks attendance AFTER raids occur

## Rails 8 Conventions

### Use Rails 8 Defaults

**Solid Queue** (not Sidekiq):
```ruby
# Use built-in background jobs
class ImportEqdkpDataJob < ApplicationJob
  queue_as :default

  def perform(guild_id, file_path)
    # Import logic
  end
end
```

**Propshaft** (not Sprockets):
- Asset pipeline is Propshaft by default
- No need to configure Sprockets

**Hotwire** (Turbo + Stimulus):
```ruby
# Use Turbo Streams for real-time updates
def create
  @raid_attendance = @raid.raid_attendances.create(attendance_params)

  respond_to do |format|
    format.turbo_stream
    format.html { redirect_to @raid }
  end
end
```

### Testing with RSpec

```ruby
# spec/models/character_spec.rb
require 'rails_helper'

RSpec.describe Character, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_inclusion_of(:eq_class).in_array(EverQuest::CLASSES) }
    it { should validate_numericality_of(:level).is_in(1..60) }
  end

  describe 'associations' do
    it { should belong_to(:guild) }
    it { should belong_to(:user).optional }
  end
end
```

### Authorization with Pundit

```ruby
# app/policies/character_policy.rb
class CharacterPolicy < ApplicationPolicy
  def update?
    user.admin? || (record.guild.officers.include?(user))
  end

  def claim?
    user.present? && record.user_id.nil?
  end
end

# In controller
def update
  @character = Character.find(params[:id])
  authorize @character
  # ...
end
```

## Common Patterns

### DKP Calculation Service

```ruby
# app/services/dkp/calculator_service.rb
module Dkp
  class CalculatorService
    def self.calculate_balance(character)
      earned = character.raid_attendances.sum(:points_earned)
      spent = character.item_awards.sum(:points_cost)
      adjustments = character.dkp_adjustments.sum(:points)

      earned - spent + adjustments
    end
  end
end
```

### Caching DKP Balances

```ruby
# app/models/character.rb
class Character < ApplicationRecord
  def current_dkp
    Rails.cache.fetch(dkp_cache_key, expires_in: 5.minutes) do
      Dkp::CalculatorService.calculate_balance(self)
    end
  end

  def invalidate_dkp_cache
    Rails.cache.delete(dkp_cache_key)
  end

  private

  def dkp_cache_key
    "character/#{id}/dkp_balance"
  end
end
```

### ViewComponents for Reusable UI

```ruby
# app/components/character_card_component.rb
class CharacterCardComponent < ViewComponent::Base
  def initialize(character:)
    @character = character
  end

  def class_color
    case @character.eq_class
    when 'Warrior' then 'text-yellow-600'
    when 'Cleric' then 'text-blue-400'
    when 'Wizard' then 'text-purple-500'
    # ... etc
    end
  end
end
```

```erb
<!-- app/components/character_card_component.html.erb -->
<div class="bg-white rounded-lg shadow p-4">
  <h3 class="<%= class_color %> font-bold"><%= @character.name %></h3>
  <p class="text-sm text-gray-600"><%= @character.eq_class %> - <%= @character.eq_race %></p>
  <p class="text-lg font-semibold">DKP: <%= @character.current_dkp %></p>
</div>
```

## Testing Guidelines

### Model Tests
- Test validations
- Test associations
- Test custom methods
- Test scopes
- Aim for 100% coverage on models

### Controller Tests
- Test authorization (Pundit policies)
- Test happy path and error cases
- Don't test view rendering (use system tests)

### System Tests (Capybara)
- Test complete user flows
- Login with Discord → Claim character → View DKP
- Admin creates raid → Adds attendees → Awards loot

### Example System Test

```ruby
# spec/system/raid_management_spec.rb
require 'rails_helper'

RSpec.describe 'Raid Management', type: :system do
  let(:officer) { create(:user, :officer) }
  let(:guild) { create(:guild) }
  let(:event_type) { create(:event_type, guild: guild, name: 'Plane of Fear') }

  before do
    sign_in officer
  end

  it 'allows officer to create raid and add attendees' do
    visit new_guild_raid_path(guild)

    select 'Plane of Fear', from: 'Event Type'
    fill_in 'Points Awarded', with: '3'
    click_button 'Create Raid'

    expect(page).to have_content('Raid created successfully')
    expect(page).to have_content('Plane of Fear')
  end
end
```

## File Organization

```
app/
├── components/          # ViewComponents (reusable UI)
├── controllers/
│   ├── admin/          # Admin-only controllers (Devise)
│   └── guilds/         # Guild-scoped controllers
├── models/
├── policies/           # Pundit authorization
├── services/           # Business logic (DKP calculations, imports)
│   ├── dkp/
│   └── importers/
├── queries/            # Complex queries (standings, analytics)
├── jobs/               # Solid Queue background jobs
└── views/

lib/
├── everquest/          # P99 constants (classes, races)
└── importers/          # EQdkpPlus migration tool

spec/
├── models/
├── controllers/
├── system/
├── services/
└── factories/          # FactoryBot factories
```

## Common Commands

```bash
# Setup
bin/setup

# Run development server
bin/dev

# Run tests
bin/test
# or
bundle exec rspec

# Run console
bin/rails console

# Database
bin/rails db:create
bin/rails db:migrate
bin/rails db:seed

# Code quality
bundle exec rubocop
bundle exec brakeman
bundle exec bundle-audit

# Background jobs (Solid Queue)
bin/rails solid_queue:start
```

## API Patterns

When building API endpoints for Discord bot or future integrations:

```ruby
# app/controllers/api/v1/dkp_controller.rb
module Api
  module V1
    class DkpController < ApiController
      def standings
        guild = Guild.find_by(slug: params[:guild_slug])
        standings = Dkp::StandingsQuery.new(guild).call

        render json: standings, each_serializer: CharacterStandingSerializer
      end

      def character
        character = Character.find_by(name: params[:name])
        render json: {
          name: character.name,
          class: character.eq_class,
          dkp: character.current_dkp,
          earned: character.raid_attendances.sum(:points_earned),
          spent: character.item_awards.sum(:points_cost)
        }
      end
    end
  end
end
```

## Security Considerations

### Authentication Flow

1. **User Login:** Discord OAuth → Create/update User record
2. **Admin Login:** Email/password via Devise → Only for `admin: true` users
3. **Session:** Rails session cookie (encrypted)
4. **CSRF:** Rails built-in CSRF protection

### Authorization

- Use Pundit for all resource access
- Never skip authorization checks
- Test policies thoroughly

### SQL Injection

- Always use parameterized queries
- Never interpolate user input into SQL

```ruby
# BAD
Character.where("name = '#{params[:name]}'")

# GOOD
Character.where(name: params[:name])
```

### Mass Assignment

```ruby
# app/controllers/characters_controller.rb
def character_params
  params.require(:character).permit(:name, :eq_class, :eq_race, :level, :rank)
end
```

## Performance Optimization

### N+1 Queries

Use Bullet gem in development to catch N+1 queries:

```ruby
# config/environments/development.rb
config.after_initialize do
  Bullet.enable = true
  Bullet.alert = true
  Bullet.bullet_logger = true
end
```

Fix with eager loading:

```ruby
# BAD
@characters = Character.all
@characters.each { |c| puts c.guild.name }  # N+1!

# GOOD
@characters = Character.includes(:guild)
@characters.each { |c| puts c.guild.name }  # 2 queries total
```

### Database Indexes

Ensure indexes exist for:
- Foreign keys (`guild_id`, `user_id`, etc.)
- Unique constraints (`discord_id`, `slug`)
- Frequently queried columns (`raid_date`, `created_at`)

### Caching Strategy

- **DKP balances:** Redis, 5 min TTL
- **Standings page:** Redis, 5 min TTL
- **Dashboard widgets:** Fragment caching
- **Guild configs:** Low-level caching

## Discord Bot Integration

When implementing Discord bot (Epic 10):

```ruby
# lib/discord_bot/runner.rb
require 'discordrb'

module DiscordBot
  class Runner
    def initialize
      @bot = Discordrb::Bot.new(token: Rails.application.credentials.discord.bot_token)
      setup_commands
    end

    def run
      @bot.run
    end

    private

    def setup_commands
      @bot.command(:dkp, min_args: 1) do |event, character_name|
        character = Character.find_by(name: character_name)
        if character
          event.respond "#{character.name} - #{character.eq_class}: #{character.current_dkp} DKP"
        else
          event.respond "Character '#{character_name}' not found"
        end
      end
    end
  end
end
```

## EQdkpPlus Migration

Key migration considerations (Epic 12):

1. **Multi-pool to Single Pool:** Consolidate or let guild choose primary pool
2. **Character Name Uniqueness:** Ensure no duplicates within guild
3. **Historical Data:** Preserve all raids, items, attendances
4. **DKP Balance Validation:** Compare old vs new balances
5. **Rollback Plan:** Transaction-based, rollback on any error

## Common Pitfalls to Avoid

1. **Don't Store DKP Balances** - Calculate them dynamically
2. **Don't Use Sidekiq** - Rails 8 has Solid Queue built-in
3. **Don't Skip Authorization** - Always use Pundit policies
4. **Don't Hardcode P99 Data** - Use constants in `lib/everquest/`
5. **Don't Use Old Asset Pipeline** - Propshaft is built-in
6. **Don't Bypass Tests** - Maintain >90% coverage
7. **Don't Forget Audit Trail** - Use PaperTrail for critical models

## Useful Resources

- **Rails 8 Guides:** https://guides.rubyonrails.org
- **Hotwire Documentation:** https://hotwired.dev
- **Tailwind CSS:** https://tailwindcss.com
- **Pundit:** https://github.com/varvet/pundit
- **RSpec Rails:** https://github.com/rspec/rspec-rails

## Development Workflow

### ⚠️ IMPORTANT: All Changes Must Go Through Pull Requests

**NEVER commit directly to `main` branch!** All changes MUST be submitted via Pull Requests with passing tests.

### Workflow Steps

1. **Pick a Task:** From GitHub Issues (#15-#191)
2. **Create Feature Branch:**
   ```bash
   git checkout main
   git pull origin main
   git checkout -b task/T1.1.5-redis-setup
   ```

3. **Write Tests First (TDD):**
   - Write failing tests before implementation
   - Follow RSpec conventions
   - Aim for >90% code coverage
   - Test all edge cases

4. **Implement Feature:**
   - Follow task acceptance criteria
   - Write clean, readable code
   - Add comments for complex logic
   - Follow Rails conventions

5. **Run Test Suite (MUST PASS):**
   ```bash
   # Run all tests
   bundle exec rspec

   # Run specific test file
   bundle exec rspec spec/models/character_spec.rb

   # Run with coverage report
   COVERAGE=true bundle exec rspec
   ```
   **Tests MUST pass before committing!**

6. **Run Code Quality Checks:**
   ```bash
   # Auto-fix style issues
   bundle exec rubocop -a

   # Security scan
   bundle exec brakeman

   # Dependency audit
   bundle exec bundle-audit
   ```

7. **Verify Changes Locally:**
   ```bash
   # Start development server
   bin/dev

   # Manual testing in browser/console
   bin/rails console
   ```

8. **Commit Changes:**
   - Use conventional commits format
   - Reference issue number
   - Include detailed description
   ```bash
   git add .
   git commit -m "feat: add Redis caching support [T1.1.5]"
   ```

9. **Push Branch:**
   ```bash
   git push -u origin task/T1.1.5-redis-setup
   ```

10. **Create Pull Request:**
    - Use PR template
    - Link to issue
    - Add screenshots if UI changes
    - Request review

11. **CI/CD Validation (Automatic):**
    - ✅ Tests pass (RSpec)
    - ✅ Linter passes (Rubocop)
    - ✅ Security scan passes (Brakeman)
    - ✅ Dependencies safe (Bundler-audit)
    - ✅ Code coverage >= 80%

12. **Code Review:**
    - Address feedback
    - Update PR as needed
    - Re-run tests after changes

13. **Merge:**
    - Maintainer approves
    - Squash and merge to main
    - Delete feature branch
    - Automatic deployment to staging

### Testing Requirements

#### Test Coverage Goals
- **Overall:** >= 90% coverage
- **Models:** 100% coverage
- **Controllers:** >= 85% coverage
- **Services:** >= 90% coverage
- **Critical paths:** 100% coverage

#### What to Test

**Models:**
```ruby
# spec/models/character_spec.rb
RSpec.describe Character, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name).scoped_to(:guild_id) }
  end

  describe 'associations' do
    it { should belong_to(:guild) }
    it { should have_many(:raid_attendances) }
  end

  describe '#current_dkp' do
    it 'calculates DKP correctly' do
      # Test implementation
    end
  end
end
```

**Controllers:**
```ruby
# spec/controllers/characters_controller_spec.rb
RSpec.describe CharactersController, type: :controller do
  describe 'GET #index' do
    it 'returns success' do
      get :index
      expect(response).to be_successful
    end
  end

  describe 'authorization' do
    it 'requires authentication' do
      # Test authorization
    end
  end
end
```

**System Tests:**
```ruby
# spec/system/character_management_spec.rb
RSpec.describe 'Character Management', type: :system do
  it 'allows officer to create character' do
    visit new_character_path
    fill_in 'Name', with: 'Legolas'
    click_button 'Create Character'
    expect(page).to have_content('Character created')
  end
end
```

**Configuration Tests:**
```ruby
# spec/config/redis_spec.rb
RSpec.describe 'Redis Configuration' do
  it 'connects to Redis' do
    expect(Redis.current.ping).to eq('PONG')
  end

  it 'uses correct cache store' do
    expect(Rails.cache.class.name).to include('RedisCacheStore')
  end
end
```

#### Test Commands

```bash
# Run all tests
bundle exec rspec

# Run specific test
bundle exec rspec spec/models/character_spec.rb:10

# Run tests with coverage
COVERAGE=true bundle exec rspec

# Run tests matching pattern
bundle exec rspec --tag focus

# Run in parallel (faster)
bundle exec rspec --format progress --order random
```

### Continuous Integration (GitHub Actions)

Every PR automatically runs:

1. **RSpec Test Suite**
   - All tests must pass
   - Coverage report generated
   - Fails if coverage < 80%

2. **Rubocop Linter**
   - Enforces style guide
   - Fails on offenses
   - Auto-fixable issues noted

3. **Brakeman Security Scan**
   - Detects security vulnerabilities
   - Fails on high/medium severity
   - Provides detailed report

4. **Bundler Audit**
   - Checks for vulnerable dependencies
   - Fails if CVEs detected
   - Suggests updates

5. **Test Matrix**
   - Ruby: 3.3.x
   - Rails: 8.0.x
   - PostgreSQL: 16
   - Redis: 7

### PR Merge Requirements

Before a PR can be merged, it MUST:

- ✅ All CI checks pass (tests, linter, security)
- ✅ Code coverage >= 80%
- ✅ At least 1 approval from maintainer
- ✅ No merge conflicts
- ✅ All conversations resolved
- ✅ Passes manual QA (if applicable)

## Questions to Ask

When implementing a feature, always consider:

1. **Authorization:** Who can access this? (Pundit policy)
2. **Validation:** What data is required/valid?
3. **Performance:** Will this scale to 1000+ characters? 10,000+ raids?
4. **Testing:** What are the edge cases?
5. **UX:** Is this intuitive for P99 guild officers?
6. **Caching:** Should this be cached?
7. **Audit Trail:** Should changes be tracked? (PaperTrail)
8. **Real-time:** Should this use Turbo Streams?

## Contributing

- Follow existing code patterns
- Write tests for all new code
- Keep PRs focused (one task per PR)
- Update documentation as needed
- Run full test suite before pushing

## Getting Help

- Check `/docs` directory for planning documents
- Review GitHub Issues for context
- Refer to this CLAUDE.md for Rails patterns
- Read Rails 8 guides for framework questions

---

**Last Updated:** October 21, 2025
**Rails Version:** 8.0+
**Ruby Version:** 3.3+
**Project Phase:** Pre-development (Planning Complete)
