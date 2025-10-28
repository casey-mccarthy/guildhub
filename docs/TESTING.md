# GuildHub Testing Guide

Complete guide for running tests in GuildHub.

---

## Quick Start

### Docker Testing (Recommended)

```bash
# Run all tests
bin/test_docker

# Run specific test
bin/test_docker spec/models/user_spec.rb
```

### Local Testing (Without Docker)

```bash
# Run all tests
bin/test_local

# Run specific test
bin/test_local spec/models/user_spec.rb
```

---

## Test Scripts

### `bin/test_docker` - Docker Testing

**Use when:**
- Using Docker for development
- Want to match production environment
- Database configured with `host: db`

**What it does:**
1. Ensures test database exists in Docker
2. Runs migrations in Docker
3. Executes RSpec in Docker container
4. Shows documentation-formatted output

**Usage:**
```bash
# All tests
bin/test_docker

# Specific file
bin/test_docker spec/models/user_spec.rb

# Specific test by line
bin/test_docker spec/models/user_spec.rb:42
```

### `bin/test_local` - Local Testing

**Use when:**
- Running PostgreSQL locally
- Not using Docker
- Want faster test execution

**What it does:**
1. Sets DATABASE_HOST=localhost
2. Ensures local test database exists
3. Runs migrations locally
4. Executes RSpec locally
5. Shows documentation-formatted output

**Prerequisites:**
- PostgreSQL running locally
- Database credentials:
  - Host: localhost
  - User: postgres (or set DATABASE_USER)
  - Password: postgres (or set DATABASE_PASSWORD)

**Usage:**
```bash
# All tests
bin/test_local

# Specific file
bin/test_local spec/models/user_spec.rb

# With custom database user
DATABASE_USER=myuser bin/test_local
```

---

## Manual Testing

### Docker Environment

**First-time setup:**
```bash
# Create test database
docker compose exec web bin/rails db:create RAILS_ENV=test

# Run migrations
docker compose exec web bin/rails db:migrate RAILS_ENV=test
```

**Run tests:**
```bash
# All tests
docker compose exec web bundle exec rspec

# Specific test file
docker compose exec web bundle exec rspec spec/models/user_spec.rb

# Specific test by line number
docker compose exec web bundle exec rspec spec/models/user_spec.rb:42

# With documentation format
docker compose exec web bundle exec rspec --format documentation

# Specific test suite
docker compose exec web bundle exec rspec spec/models/
docker compose exec web bundle exec rspec spec/requests/
docker compose exec web bundle exec rspec spec/system/
```

### Local Environment

**First-time setup:**
```bash
# Set database connection (add to ~/.bashrc or ~/.zshrc)
export DATABASE_HOST=localhost
export DATABASE_USER=postgres
export DATABASE_PASSWORD=postgres

# Create test database
RAILS_ENV=test bin/rails db:create

# Run migrations
RAILS_ENV=test bin/rails db:migrate
```

**Run tests:**
```bash
# All tests
bundle exec rspec

# Specific test file
bundle exec rspec spec/models/user_spec.rb

# Specific test by line number
bundle exec rspec spec/models/user_spec.rb:42

# With documentation format
bundle exec rspec --format documentation

# With progress format (dots)
bundle exec rspec --format progress

# With coverage report
COVERAGE=true bundle exec rspec

# Parallel execution (faster)
bundle exec rspec --format progress --order random
```

---

## Test Organization

```
spec/
├── models/              # Model tests
│   ├── user_spec.rb
│   └── ...
├── controllers/         # Controller tests
│   ├── application_controller_spec.rb
│   └── auth/
│       └── callbacks_controller_spec.rb
├── requests/            # Request/integration tests
│   ├── auth/
│   │   └── callbacks_spec.rb
│   └── sessions_spec.rb
├── system/              # End-to-end browser tests
│   └── discord_authentication_spec.rb
├── config/              # Configuration tests
│   ├── discord_credentials_spec.rb
│   └── omniauth_spec.rb
├── factories/           # FactoryBot factories
│   └── users.rb
├── support/             # Test helpers
└── rails_helper.rb      # RSpec configuration
```

---

## Test Coverage

### Viewing Coverage Reports

After running tests with coverage:

```bash
# Generate coverage report
COVERAGE=true bundle exec rspec

# Open coverage report
open coverage/index.html
```

### Coverage Goals

- **Overall:** >= 90%
- **Models:** 100%
- **Controllers:** >= 85%
- **Services:** >= 90%
- **Critical paths:** 100%

### Coverage Report Location

- **HTML Report:** `coverage/index.html`
- **JSON Data:** `coverage/.resultset.json`

**Note:** Coverage files are git-ignored (don't commit them)

---

## Test Types

### Model Tests

**Location:** `spec/models/`

**Test:**
- Validations
- Associations
- Scopes
- Class methods
- Instance methods
- Callbacks

**Example:**
```ruby
# spec/models/user_spec.rb
RSpec.describe User, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:discord_id) }
  end

  describe '#display_name' do
    it 'returns discord username' do
      user = create(:user, discord_username: 'test#1234')
      expect(user.display_name).to eq('test#1234')
    end
  end
end
```

### Request Tests

**Location:** `spec/requests/`

**Test:**
- HTTP requests/responses
- Authentication flows
- Authorization
- JSON responses

**Example:**
```ruby
# spec/requests/auth/callbacks_spec.rb
RSpec.describe 'Auth::Callbacks', type: :request do
  it 'creates user from OAuth' do
    get auth_callback_path(provider: 'discord')
    expect(response).to redirect_to(root_path)
  end
end
```

### System Tests

**Location:** `spec/system/`

**Test:**
- Complete user flows
- Browser interactions
- JavaScript functionality
- End-to-end scenarios

**Example:**
```ruby
# spec/system/discord_authentication_spec.rb
RSpec.describe 'Discord Authentication', type: :system do
  it 'allows user to login' do
    visit root_path
    click_link 'Login with Discord'
    expect(page).to have_content('Successfully signed in')
  end
end
```

---

## Common Test Commands

### Run Specific Tests

```bash
# By file
bundle exec rspec spec/models/user_spec.rb

# By line number
bundle exec rspec spec/models/user_spec.rb:42

# By tag
bundle exec rspec --tag focus

# By pattern
bundle exec rspec --pattern "spec/**/*_auth_*_spec.rb"
```

### Test Output Formats

```bash
# Documentation (verbose, readable)
bundle exec rspec --format documentation

# Progress (dots: . F E)
bundle exec rspec --format progress

# JSON (for CI/CD)
bundle exec rspec --format json

# JUnit XML (for CI/CD)
bundle exec rspec --format RspecJunitFormatter
```

### Test Filtering

```bash
# Run only failed tests from last run
bundle exec rspec --only-failures

# Run tests that match description
bundle exec rspec -e "creates user from OAuth"

# Exclude slow tests
bundle exec rspec --tag ~slow
```

---

## Debugging Tests

### Using Debug Gem

Add breakpoint in test:
```ruby
it 'creates user' do
  debugger  # Execution stops here
  user = create(:user)
  expect(user).to be_valid
end
```

Run test and interact:
```bash
bundle exec rspec spec/models/user_spec.rb:42

# When stopped at debugger:
(rdb) user.attributes
(rdb) continue
```

### Using Pry

If using pry-byebug:
```ruby
it 'creates user' do
  binding.pry  # Execution stops here
  user = create(:user)
end
```

### Verbose Output

```bash
# Show all SQL queries
bundle exec rspec --format documentation --backtrace

# Show warnings
bundle exec rspec --warnings

# Show profile (slowest tests)
bundle exec rspec --profile 10
```

---

## Troubleshooting

### Database Connection Errors (Docker)

**Error:** `could not translate host name "db"`

**Solution:**
```bash
# Ensure Docker containers are running
docker compose ps

# Use Docker test script
bin/test_docker
```

### Database Connection Errors (Local)

**Error:** `FATAL: database "guildhub_test" does not exist`

**Solution:**
```bash
# Create test database
RAILS_ENV=test bin/rails db:create
RAILS_ENV=test bin/rails db:migrate
```

### Pending Migrations

**Error:** `Migrations are pending`

**Solution:**
```bash
# Docker
docker compose exec web bin/rails db:migrate RAILS_ENV=test

# Local
RAILS_ENV=test bin/rails db:migrate
```

### Factory Not Found

**Error:** `Factory not registered: user`

**Solution:**
```bash
# Ensure factories are loaded
# Check spec/rails_helper.rb has:
require 'factory_bot_rails'

# Verify factory exists
ls spec/factories/users.rb
```

### Slow Tests

**Issue:** Tests take too long

**Solutions:**
```bash
# Use test database (not development)
RAILS_ENV=test bundle exec rspec

# Run in parallel
bundle exec rspec --format progress

# Profile slowest tests
bundle exec rspec --profile 10

# Use FactoryBot build instead of create
user = build(:user)  # Don't save to DB
```

---

## Continuous Integration

### GitHub Actions

Tests run automatically on every PR:

```yaml
# .github/workflows/ci.yml
- name: Run tests
  run: bundle exec rspec

- name: Check coverage
  run: |
    COVERAGE=true bundle exec rspec
    # Fails if coverage < 80%
```

### Pre-Commit Hook

Add to `.git/hooks/pre-commit`:

```bash
#!/bin/bash
echo "Running tests..."
bundle exec rspec
if [ $? -ne 0 ]; then
  echo "Tests failed! Commit aborted."
  exit 1
fi
```

---

## Best Practices

### Before Every Commit

```bash
# MANDATORY: Run ALL tests
bundle exec rspec
# OR: bin/test_docker (if using Docker)

# ALL tests MUST pass
# 0 failures, 0 errors required
```

### Writing Good Tests

```ruby
# DO: Descriptive test names
it 'creates user when discord_id is unique' do

# DON'T: Vague test names
it 'works' do

# DO: One assertion per test
it 'sets discord_id' do
  user = create(:user, discord_id: '123')
  expect(user.discord_id).to eq('123')
end

# DON'T: Multiple unrelated assertions
it 'creates user' do
  user = create(:user)
  expect(user).to be_valid
  expect(User.count).to eq(1)
  expect(user.admin).to be false
  # Too many concerns in one test
end

# DO: Use factories
user = create(:user)

# DON'T: Manual object creation in tests
user = User.create!(discord_id: '123', discord_username: 'test', ...)
```

### Test Data Cleanup

```ruby
# RSpec automatically cleans database between tests
# using DatabaseCleaner

# If you need manual cleanup:
after(:each) do
  User.destroy_all
end
```

---

## Environment Variables

### Test-Specific Environment Variables

```bash
# Database
DATABASE_HOST=localhost
DATABASE_USER=postgres
DATABASE_PASSWORD=postgres

# Rails
RAILS_ENV=test

# Coverage
COVERAGE=true
```

### Setting Environment Variables

```bash
# Per-command
DATABASE_HOST=localhost bundle exec rspec

# In shell session
export DATABASE_HOST=localhost
bundle exec rspec

# In .env.test file
echo "DATABASE_HOST=localhost" > .env.test
bundle exec rspec
```

---

## Resources

- **RSpec Documentation:** https://rspec.info/documentation/
- **FactoryBot:** https://github.com/thoughtbot/factory_bot/blob/master/GETTING_STARTED.md
- **Capybara (System Tests):** https://github.com/teamcapybara/capybara#using-capybara-with-rspec
- **SimpleCov (Coverage):** https://github.com/simplecov-ruby/simplecov

---

**Questions?** See [DEVELOPMENT.md](DEVELOPMENT.md) or ask in GitHub Discussions.

*Last Updated: October 27, 2025*
