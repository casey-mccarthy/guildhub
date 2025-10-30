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

### ⚠️ CRITICAL RULES FOR ALL COMMITS

**1. NEVER commit directly to `main` branch!**
- All changes MUST go through Pull Requests
- The `main` branch is protected
- All development happens on feature branches
- This applies to both human developers AND AI assistants

**2. ALL TESTS MUST PASS before committing!**
- Run `bundle exec rspec` (or `docker-compose exec web bundle exec rspec`)
- ALL tests must be GREEN (0 failures, 0 errors)
- Coverage must be >= 80%
- **NO EXCEPTIONS** - If tests fail, fix them before committing

**3. Pre-Commit Checklist (MANDATORY):**
```bash
# Step 1: Run tests (REQUIRED - must pass)
docker-compose exec web bundle exec rspec
# OR: bundle exec rspec

# Step 2: Run linter (auto-fix issues)
bundle exec rubocop -a

# Step 3: Run security scan
bundle exec brakeman

# Step 4: Manual verification (if UI changes)
# Start server and test manually
docker-compose up -d
# Visit: http://localhost:3000

# Step 5: Commit only if ALL checks pass
git add .
git commit -m "feat: description [TaskID]"
```

### Workflow Steps

1. **Pick a Task:** From GitHub Issues (#15-#191)
2. **Create Feature Branch:**
   ```bash
   git checkout main
   git pull origin main
   git checkout -b task/T1.1.5-redis-setup
   # or
   git checkout -b feature/discord-oauth
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

   **⚠️ CRITICAL: ALL TESTS MUST PASS BEFORE COMMITTING. NO EXCEPTIONS.**

   ```bash
   # LOCAL TESTING
   # Run all tests
   bundle exec rspec

   # Run specific test file
   bundle exec rspec spec/models/character_spec.rb

   # Run with coverage report
   COVERAGE=true bundle exec rspec

   # DOCKER TESTING (if database configured for Docker)
   # First time setup (once per project)
   docker-compose exec web bin/rails db:create RAILS_ENV=test
   docker-compose exec web bin/rails db:migrate RAILS_ENV=test

   # Run all tests in Docker
   docker-compose exec web bundle exec rspec

   # Run specific test in Docker
   docker-compose exec web bundle exec rspec spec/models/user_spec.rb

   # Run with documentation format
   docker-compose exec web bundle exec rspec --format documentation
   ```

   **Required Test Results:**
   - ✅ ALL examples passing (green output)
   - ✅ 0 failures, 0 errors
   - ✅ Coverage >= 80% (check coverage/index.html)
   - ✅ No pending tests

   **If ANY test fails:**
   - ❌ DO NOT commit
   - Fix failing tests immediately
   - Re-run full test suite
   - Only commit when ALL tests pass

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

### Conventional Commits

All commits MUST follow the [Conventional Commits](https://www.conventionalcommits.org/) specification.

**Format:**
```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:**
- `feat:` - New feature (triggers MINOR version bump)
- `fix:` - Bug fix (triggers PATCH version bump)
- `docs:` - Documentation changes
- `style:` - Code style changes (formatting, missing semicolons, etc.)
- `refactor:` - Code refactoring (no functional changes)
- `perf:` - Performance improvements
- `test:` - Adding or updating tests
- `chore:` - Maintenance tasks (dependencies, build process, etc.)
- `ci:` - CI/CD changes
- `revert:` - Revert previous commit

**Breaking Changes:**
- Add `!` after type/scope: `feat!:` or `feat(api)!:`
- Or include `BREAKING CHANGE:` in footer (triggers MAJOR version bump)

**Examples:**
```bash
# Feature with issue reference
feat: add Discord OAuth authentication [T2.1.1]

Implements Discord OAuth as primary authentication method.

- Add OmniAuth Discord provider
- Create callback controller
- Store Discord avatar URL
- Set user session

Resolves #18

# Bug fix
fix(dkp): correct balance calculation for negative adjustments

The DKP calculator was not properly handling negative adjustments
when calculating historical balances.

Fixes #142

# Breaking change
feat(api)!: change DKP endpoint response structure

BREAKING CHANGE: The /api/v1/dkp endpoint now returns an object
instead of an array. Clients must update their integration.

# Chore
chore: upgrade Rails from 8.0.0 to 8.0.1

# Documentation
docs: add Redis configuration guide to CLAUDE.md
```

**Commit Body Template:**
```
<type>: <short summary> [TaskID]

<detailed description>

**Changes:**
- Change 1
- Change 2
- Change 3

**Why:**
<reasoning for the change>

Resolves #<issue-number>

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

### Semantic Versioning

GuildHub follows [Semantic Versioning](https://semver.org/) (SemVer): `MAJOR.MINOR.PATCH`

**Version Format:** `X.Y.Z` (e.g., `1.2.3`)

- **MAJOR (X):** Breaking changes (incompatible API changes)
  - Triggered by: `feat!:`, `fix!:`, or `BREAKING CHANGE:` in commit
  - Example: `1.0.0` → `2.0.0`
  - When: Database migrations that break compatibility, API changes, major refactors

- **MINOR (Y):** New features (backwards-compatible)
  - Triggered by: `feat:` commits
  - Example: `1.2.3` → `1.3.0`
  - When: New functionality, new endpoints, new models

- **PATCH (Z):** Bug fixes (backwards-compatible)
  - Triggered by: `fix:` commits
  - Example: `1.2.3` → `1.2.4`
  - When: Bug fixes, security patches, documentation updates

**Pre-release Versions:**
- Development: `0.x.x` (before first production release)
- Alpha: `1.0.0-alpha.1`
- Beta: `1.0.0-beta.1`
- Release Candidate: `1.0.0-rc.1`

**Version Tags:**
```bash
# Create a new version tag
git tag -a v1.2.3 -m "Release version 1.2.3"
git push origin v1.2.3
```

**Current Version:** `0.1.0` (pre-development phase)

**Version History:**
- `0.1.0` - Initial project setup (Rails 8, Docker, credentials)
- `0.2.0` - Authentication system (Discord OAuth, Devise)
- `0.3.0` - Guild & Character management
- `0.4.0` - DKP tracking system
- `1.0.0` - First production release (after all 4 phases complete)

### Pull Request Guidelines

**PR Title Format:**
```
[TaskID] Type: Short description
```

**Examples:**
```
[T1.1.4] feat: Configure Rails credentials and secrets management
[T2.1.1] feat: Add Discord OAuth authentication
[T3.2.1] fix: Character validation allows invalid classes
```

**PR Description Template:**
```markdown
## Description
Brief description of changes

## Related Issue
Closes #123

## Type of Change
- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update

## Changes Made
- Change 1
- Change 2
- Change 3

## Testing
- [ ] Tests pass locally (`bin/test`)
- [ ] Linter passes (`bundle exec rubocop`)
- [ ] Manual testing completed

## Screenshots (if applicable)
Add screenshots here

## Checklist
- [ ] Code follows project style guidelines
- [ ] Self-review completed
- [ ] Comments added for complex logic
- [ ] Documentation updated
- [ ] No console warnings/errors
- [ ] Tests added/updated
- [ ] All acceptance criteria met
```

**PR Best Practices:**
- Keep PRs small and focused (one task per PR)
- Link to the corresponding GitHub issue
- Request review from maintainer
- Respond to review comments promptly
- Squash commits before merging (maintainer will do this)
- Delete branch after merge

### Branch Naming Conventions

```
task/T<epic>.<section>.<task>-<short-description>
feature/<feature-name>
fix/<bug-description>
chore/<maintenance-task>
docs/<documentation-update>
```

**Examples:**
```
task/T1.1.4-rails-credentials
task/T2.1.1-discord-oauth
feature/character-claiming
fix/dkp-calculation-bug
chore/upgrade-rails-8.0.1
docs/update-readme
```

### Code Review Process

1. **Create PR** - Push branch and create PR on GitHub
2. **Automated Checks** - CI/CD runs tests, linter, security scan
3. **Manual Review** - Maintainer reviews code
4. **Feedback** - Address review comments, push updates
5. **Approval** - Maintainer approves PR
6. **Merge** - Maintainer squashes and merges to main
7. **Cleanup** - Delete feature branch
8. **Deploy** - Automatic deployment to staging

### Git Best Practices

**DO:**
- ✅ Create feature branches from `main`
- ✅ Write descriptive commit messages
- ✅ Commit frequently (atomic commits)
- ✅ Pull latest `main` before creating branch
- ✅ Rebase on `main` if needed: `git rebase main`
- ✅ Use conventional commit format
- ✅ Reference issue numbers in commits
- ✅ Test before committing

**DON'T:**
- ❌ NEVER commit directly to `main`
- ❌ Don't commit secrets or credentials
- ❌ Don't commit large binary files
- ❌ Don't commit commented-out code
- ❌ Don't commit `binding.pry` or debugger statements
- ❌ Don't force push to shared branches
- ❌ Don't merge without approval
- ❌ Don't commit broken tests

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
