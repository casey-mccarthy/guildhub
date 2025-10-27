# GuildHub Development Guide

This guide covers day-to-day development tasks for working on GuildHub.

## Table of Contents
- [Running the Development Server](#running-the-development-server)
- [Development Tools](#development-tools)
- [Testing](#testing)
- [Database Management](#database-management)
- [Debugging](#debugging)
- [Common Tasks](#common-tasks)

---

## Running the Development Server

### Quick Start

```bash
# Start the full development environment
bin/dev
```

This starts:
- **Rails server** on `http://localhost:3000` (with Ruby debugging enabled)
- **Tailwind CSS watcher** (automatically rebuilds CSS when files change)

Visit the app at: **http://localhost:3000**

### Alternative: Rails Server Only

If you only need the Rails server without the CSS watcher:

```bash
bin/rails server
# or shorthand
bin/rails s
```

### Using a Different Port

```bash
bin/rails server -p 3001
```

Then visit: `http://localhost:3001`

### Stopping the Server

Press `Ctrl+C` in the terminal

### Checking if Server is Running

```bash
# Check if port 3000 is in use
lsof -i :3000

# Or open in browser
open http://localhost:3000
```

---

## Development Tools

### Rails Console

Interactive Ruby console with Rails environment loaded:

```bash
bin/rails console
# or shorthand
bin/rails c
```

**Useful console commands:**
```ruby
# Reload the console after code changes
reload!

# Check routes
Rails.application.routes.url_helpers

# Query models
User.count
Guild.first
Character.where(eq_class: 'Warrior')

# Test services
Dkp::CalculatorService.calculate_balance(character)
```

### Database Console

Direct PostgreSQL console:

```bash
bin/rails dbconsole
# or shorthand
bin/rails db
```

### Routes

View all application routes:

```bash
bin/rails routes

# Search for specific route
bin/rails routes | grep discord

# Show routes for specific controller
bin/rails routes -c guilds
```

---

## Testing

### Running Tests

```bash
# Run all tests
bin/test

# Or use RSpec directly
bundle exec rspec

# Run specific test file
bundle exec rspec spec/models/character_spec.rb

# Run specific test by line number
bundle exec rspec spec/models/character_spec.rb:42

# Run tests with documentation format
bundle exec rspec --format documentation

# Run tests with coverage report
COVERAGE=true bundle exec rspec
```

### Test Shortcuts

```bash
# Run only model tests
bundle exec rspec spec/models

# Run only controller tests
bundle exec rspec spec/controllers

# Run only system tests
bundle exec rspec spec/system

# Run tests matching a pattern
bundle exec rspec --pattern "spec/**/*_spec.rb"
```

### Watching Tests

For continuous test running (requires guard gem):

```bash
bundle exec guard
```

---

## Database Management

### Basic Operations

```bash
# Create database
bin/rails db:create

# Run pending migrations
bin/rails db:migrate

# Rollback last migration
bin/rails db:rollback

# Rollback multiple migrations
bin/rails db:rollback STEP=3

# Seed sample data
bin/rails db:seed

# Reset database (drop, create, migrate, seed)
bin/rails db:reset

# Drop database
bin/rails db:drop
```

### Migration Workflow

```bash
# Generate a new migration
bin/rails generate migration AddRankToCharacters rank:string

# Check migration status
bin/rails db:migrate:status

# Run specific migration
bin/rails db:migrate:up VERSION=20251027123456

# Redo last migration
bin/rails db:migrate:redo
```

### Database Inspection

```bash
# Show schema version
bin/rails db:version

# Validate database schema
bin/rails db:schema:dump

# Load schema (faster than migrations)
bin/rails db:schema:load
```

---

## Code Quality

### Linting with Rubocop

```bash
# Run Rubocop (check style issues)
bundle exec rubocop

# Auto-fix safe issues
bundle exec rubocop -a

# Auto-fix all issues (including unsafe)
bundle exec rubocop -A

# Check specific files
bundle exec rubocop app/models/character.rb

# Generate TODO list for existing offenses
bundle exec rubocop --auto-gen-config
```

### Security Scanning

```bash
# Run Brakeman security scan
bundle exec brakeman

# Brakeman with detailed output
bin/brakeman

# Check for vulnerable dependencies
bundle exec bundle-audit

# Update vulnerability database
bundle exec bundle-audit update
```

---

## Debugging

### Using Debug Gem

Add breakpoints in your code:

```ruby
# In any Ruby file
debugger

# Or use binding.pry (if using pry-byebug)
binding.pry
```

When the breakpoint is hit:

```
# Continue execution
continue

# Step to next line
next

# Step into method
step

# Show backtrace
backtrace

# Evaluate variables
@character.name
params

# Exit debugger
exit
```

### Rails Logging

```bash
# Watch development log
tail -f log/development.log

# Watch test log
tail -f log/test.log

# Clear logs
bin/rails log:clear
```

### Better Errors

When running `bin/dev`, any errors in development will show:
- Interactive stack trace
- Local variables at each stack frame
- REPL console in browser

---

## Common Tasks

### Cache Management

```bash
# Clear Rails cache
bin/rails tmp:cache:clear

# Clear Redis cache (if using Redis)
bin/rails runner "Rails.cache.clear"
```

### Asset Management

```bash
# Precompile assets (for production testing)
bin/rails assets:precompile

# Clean compiled assets
bin/rails assets:clean

# Rebuild Tailwind CSS
yarn build:css
```

### Background Jobs

```bash
# Start Solid Queue worker
bin/rails solid_queue:start

# Check job status in console
bin/rails c
> SolidQueue::Job.all
> SolidQueue::FailedExecution.all
```

### Credentials Management

```bash
# Edit credentials (opens in $EDITOR)
bin/rails credentials:edit

# Edit production credentials
bin/rails credentials:edit --environment production

# Show credentials (decrypted)
bin/rails credentials:show
```

### Generate Code

```bash
# Generate model
bin/rails generate model Character name:string eq_class:string level:integer

# Generate controller
bin/rails generate controller Guilds index show new create

# Generate migration
bin/rails generate migration AddSlugToGuilds slug:string:uniq

# Generate RSpec test
bin/rails generate rspec:model Character

# List all generators
bin/rails generate --help
```

---

## Docker Development

### Using Docker Compose

```bash
# Start all services (web, postgres, redis)
docker-compose up

# Start in background
docker-compose up -d

# View logs
docker-compose logs -f web

# Run migrations in container
docker-compose exec web bin/rails db:migrate

# Access Rails console in container
docker-compose exec web bin/rails console

# Run tests in container
docker-compose exec web bin/test

# Stop all services
docker-compose down

# Remove volumes (resets database)
docker-compose down -v
```

---

## Performance Profiling

### Rack Mini Profiler

When enabled in development, you'll see:
- Page load time badge
- SQL query count
- Click badge for detailed breakdown

### Bullet Gem (N+1 Detection)

If enabled in `config/environments/development.rb`:
- Alerts appear in browser when N+1 queries detected
- Check `log/bullet.log` for details

---

## Troubleshooting

### Server Won't Start

```bash
# Check if port 3000 is already in use
lsof -i :3000

# Kill process on port 3000
kill -9 $(lsof -t -i:3000)

# Check for pending migrations
bin/rails db:migrate:status
```

### Database Connection Issues

```bash
# Check PostgreSQL is running
pg_isready

# Or with specific details
psql -U postgres -c "SELECT version();"

# Verify database.yml configuration
cat config/database.yml
```

### Redis Connection Issues

```bash
# Check Redis is running
redis-cli ping
# Should return: PONG

# Start Redis (macOS with Homebrew)
brew services start redis

# Start Redis (Linux)
sudo systemctl start redis
```

### Asset Issues

```bash
# Clear tmp files
bin/rails tmp:clear

# Rebuild assets
yarn build:css
bin/rails assets:clobber
bin/rails assets:precompile
```

### Test Database Issues

```bash
# Ensure test database exists
RAILS_ENV=test bin/rails db:create

# Load test schema
RAILS_ENV=test bin/rails db:schema:load

# Reset test database
RAILS_ENV=test bin/rails db:reset
```

---

## Best Practices

### Before Starting Work

1. Pull latest changes: `git pull origin main`
2. Install dependencies: `bundle install && yarn install`
3. Run migrations: `bin/rails db:migrate`
4. Run tests: `bin/test`

### Before Committing

1. Run tests: `bin/test` (must pass)
2. Run linter: `bundle exec rubocop -a`
3. Check security: `bundle exec brakeman`
4. Review changes: `git diff`

### Daily Development Flow

```bash
# Morning routine
git pull origin main
bundle install
bin/rails db:migrate
bin/dev

# Development loop
# - Make changes
# - Write tests
# - Run tests: bin/test
# - Check in browser: http://localhost:3000

# Before committing
bin/test
bundle exec rubocop -a
git add .
git commit -m "feat: add feature [T2.1.1]"
git push
```

---

## Additional Resources

- **Rails Guides:** https://guides.rubyonrails.org
- **Rails Console Guide:** https://guides.rubyonrails.org/command_line.html#bin-rails-console
- **Debugging Rails:** https://guides.rubyonrails.org/debugging_rails_applications.html
- **RSpec Documentation:** https://rspec.info
- **Rubocop Documentation:** https://docs.rubocop.org

---

**Need help?** Check the [README.md](README.md) or ask in GitHub Discussions.

*Last Updated: October 27, 2025*
