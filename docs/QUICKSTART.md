# GuildHub Quick Start Guide

**Complete setup guide from a blank macOS terminal**

---

## Prerequisites Check

Open Terminal and verify what you have installed:

```bash
# Check if you have these installed
ruby --version       # Should be 3.3+
rails --version      # Should be 8.0+
docker --version     # Any recent version
psql --version       # PostgreSQL 16+
git --version        # Any recent version
```

**Don't have these?** Follow the [Installation](#installation) section below.

---

## Option 1: Docker Setup (Recommended - Easiest)

**If you have Docker installed**, this is the fastest way:

### Step 1: Clone and Navigate

```bash
# Navigate to project directory (if not already there)
cd ~/Documents/GitHub/guildhub
```

### Step 2: Start Docker

```bash
# Start Docker Desktop app
# (Find in Applications or use Spotlight: Cmd+Space, type "Docker")

# Verify Docker is running
docker ps
# Should show running containers or empty table (not an error)
```

### Step 3: Build and Start Containers

```bash
# Build Docker images
docker compose build

# Start all containers (PostgreSQL, Redis, Web server)
docker compose up -d

# Verify containers are running
docker compose ps
# Should show: web, db, redis all "Up"
```

### Step 4: Setup Database

```bash
# Create databases
docker compose exec web bin/rails db:create

# Run migrations
docker compose exec web bin/rails db:migrate

# Create test database
docker compose exec web bin/rails db:create RAILS_ENV=test
docker compose exec web bin/rails db:migrate RAILS_ENV=test
```

### Step 5: Setup Discord App

Follow the guide to create Discord OAuth app:

```bash
# Open the guide
open docs/DISCORD_SETUP.md

# Or view in terminal
cat docs/DISCORD_SETUP.md
```

**Summary of Discord setup:**
1. Go to https://discord.com/developers/applications
2. Click "New Application"
3. Name it "GuildHub Dev"
4. Go to OAuth2 → General
5. Copy Client ID and Client Secret
6. Add redirect URI: `http://localhost:3000/auth/discord/callback`
7. Save changes

### Step 6: Configure Credentials

```bash
# Edit Rails credentials
docker compose exec web bin/rails credentials:edit

# This opens an editor. Add this structure:
discord:
  client_id: "YOUR_CLIENT_ID_FROM_DISCORD"
  client_secret: "YOUR_CLIENT_SECRET_FROM_DISCORD"

# Save and close:
# - In vim: Press ESC, type :wq, press ENTER
# - In nano: Press Ctrl+X, Y, ENTER
```

### Step 7: Run Tests

```bash
# Run all tests
bin/test_docker

# Expected: 82 examples, 0 failures
```

### Step 8: View Application

```bash
# Application is running at:
open http://localhost:3000

# You should see:
# - "GuildHub" heading
# - "Login with Discord" button
# - EverQuest themed page
```

### Step 9: Test Login

1. Click "Login with Discord"
2. Authorize the app on Discord
3. You'll be redirected back
4. Should see your Discord username and avatar

**Done! You're all set with Docker.**

---

## Option 2: Local Development (Without Docker)

**If you DON'T want to use Docker**, run everything locally:

### Step 1: Install Dependencies

```bash
# Install Homebrew (if not installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install PostgreSQL
brew install postgresql@16

# Install Redis
brew install redis

# Install Node.js (for Tailwind CSS)
brew install node

# Install rbenv (Ruby version manager)
brew install rbenv ruby-build

# Install Ruby 3.3
rbenv install 3.3.0
rbenv global 3.3.0

# Verify Ruby version
ruby --version
# Should show: ruby 3.3.0 or higher
```

### Step 2: Start Services

```bash
# Start PostgreSQL
brew services start postgresql@16

# Start Redis
brew services start redis

# Verify they're running
brew services list
# Should show postgresql@16 and redis as "started"
```

### Step 3: Clone and Setup Project

```bash
# Navigate to project
cd ~/Documents/GitHub/guildhub

# Install Ruby gems
bundle install

# Install Node packages
npm install
# Or: yarn install

# Create databases
bin/rails db:create

# Run migrations
bin/rails db:migrate

# Create test database
RAILS_ENV=test bin/rails db:create
RAILS_ENV=test bin/rails db:migrate
```

### Step 4: Setup Discord App

Same as Docker (Step 5 above):

```bash
open docs/DISCORD_SETUP.md
```

Create Discord app and get credentials.

### Step 5: Configure Credentials

```bash
# Edit Rails credentials
bin/rails credentials:edit

# Add Discord credentials (same as Docker Step 6)
```

### Step 6: Run Tests

```bash
# Run all tests locally
bin/test_local

# Expected: 82 examples, 0 failures
```

### Step 7: Start Development Server

```bash
# Start Rails server and Tailwind watcher
bin/dev

# Application running at:
# http://localhost:3000
```

### Step 8: View Application

```bash
# Open in browser
open http://localhost:3000
```

**Done! You're all set with local development.**

---

## Installation (If Missing Prerequisites)

### Install Homebrew

```bash
# Install Homebrew package manager
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Follow on-screen instructions to add to PATH
```

### Install Docker Desktop

```bash
# Download Docker Desktop for Mac
open https://www.docker.com/products/docker-desktop/

# Or install with Homebrew
brew install --cask docker

# Launch Docker Desktop app
open -a Docker

# Wait for Docker to start (whale icon in menu bar)
```

### Install PostgreSQL (for local development)

```bash
# Install PostgreSQL 16
brew install postgresql@16

# Start PostgreSQL
brew services start postgresql@16

# Create your user (if needed)
createuser -s postgres

# Verify it's running
psql postgres -c "SELECT version();"
```

### Install Ruby

```bash
# Install rbenv (Ruby version manager)
brew install rbenv ruby-build

# Add rbenv to your shell
echo 'eval "$(rbenv init -)"' >> ~/.zshrc
source ~/.zshrc

# Install Ruby 3.3.0
rbenv install 3.3.0
rbenv global 3.3.0

# Verify installation
ruby --version
# Should show: ruby 3.3.0
```

### Install Node.js

```bash
# Install Node.js (for JavaScript/CSS bundling)
brew install node

# Verify installation
node --version
npm --version
```

### Install Git (Usually pre-installed on macOS)

```bash
# Check if Git is installed
git --version

# If not, install via Xcode Command Line Tools
xcode-select --install
```

---

## Common Commands

### Docker Commands

```bash
# Start containers
docker compose up -d

# Stop containers
docker compose down

# View logs
docker compose logs -f web

# Rebuild containers
docker compose build

# Run Rails console
docker compose exec web bin/rails console

# Run database migrations
docker compose exec web bin/rails db:migrate

# Run tests
bin/test_docker
```

### Local Development Commands

```bash
# Start development server
bin/dev

# Run Rails console
bin/rails console

# Run database migrations
bin/rails db:migrate

# Run tests
bin/test_local

# Start PostgreSQL
brew services start postgresql@16

# Stop PostgreSQL
brew services stop postgresql@16
```

---

## Verify Everything Works

### Check Docker Setup

```bash
# From project directory
cd ~/Documents/GitHub/guildhub

# Check containers are running
docker compose ps
# Should show: web, db, redis all "Up"

# Check database connection
docker compose exec web bin/rails runner "puts User.count"
# Should show: 0 (or number of users)

# Check home page
curl http://localhost:3000 | grep "GuildHub"
# Should show HTML with "GuildHub"

# Run tests
bin/test_docker
# Should show: 82 examples, 0 failures
```

### Check Local Setup

```bash
# From project directory
cd ~/Documents/GitHub/guildhub

# Check PostgreSQL is running
pg_isready
# Should show: accepting connections

# Check Redis is running
redis-cli ping
# Should show: PONG

# Check database connection
bin/rails runner "puts User.count"
# Should show: 0 (or number of users)

# Run tests
bin/test_local
# Should show: 82 examples, 0 failures

# Start server
bin/dev
# Visit: http://localhost:3000
```

---

## Troubleshooting

### "command not found: docker compose"

**Solution:**
```bash
# Ensure Docker Desktop is installed and running
open -a Docker

# Wait for Docker to fully start (whale icon in menu bar shows "Docker is running")

# Try again
docker compose version
```

### "Error: No such file or directory"

**Solution:**
```bash
# Make sure you're in the project directory
pwd
# Should show: /Users/casey/Documents/GitHub/guildhub

# If not, navigate there:
cd ~/Documents/GitHub/guildhub
```

### "database does not exist"

**Solution with Docker:**
```bash
docker compose exec web bin/rails db:create
docker compose exec web bin/rails db:migrate
```

**Solution locally:**
```bash
bin/rails db:create
bin/rails db:migrate
```

### "Permission denied: bin/test_docker"

**Solution:**
```bash
# Make scripts executable
chmod +x bin/test_docker bin/test_local

# Try again
bin/test_docker
```

### "Could not connect to server"

**Docker:**
```bash
# Ensure containers are running
docker compose up -d
docker compose ps
```

**Local:**
```bash
# Ensure PostgreSQL is running
brew services start postgresql@16
pg_isready
```

### "Port already in use"

**Solution:**
```bash
# Find what's using port 3000
lsof -i :3000

# Kill the process
kill -9 <PID>

# Or use a different port
docker compose up -d
# Then edit docker-compose.yml to use different port
```

---

## What's Next?

After setup is complete:

1. **Read the test plan:** `docs/DISCORD_OAUTH_TEST_PLAN.md`
2. **Try logging in:** Click "Login with Discord" at http://localhost:3000
3. **Run manual tests:** Follow test cases in test plan
4. **Start development:** Check `CLAUDE.md` for development workflow
5. **View documentation:** All docs in `docs/` directory

---

## Quick Reference Card

```bash
# === DOCKER WORKFLOW ===

# Start everything
docker compose up -d

# Run tests
bin/test_docker

# View app
open http://localhost:3000

# Rails console
docker compose exec web bin/rails console

# View logs
docker compose logs -f web

# Stop everything
docker compose down


# === LOCAL WORKFLOW ===

# Start services
brew services start postgresql@16
brew services start redis

# Run tests
bin/test_local

# Start app
bin/dev

# View app
open http://localhost:3000

# Rails console
bin/rails console

# Stop services
brew services stop postgresql@16
brew services stop redis
```

---

## Help and Resources

- **Main README:** `README.md`
- **Development Guide:** `DEVELOPMENT.md` (created earlier)
- **Testing Guide:** `docs/TESTING.md`
- **Discord Setup:** `docs/DISCORD_SETUP.md`
- **Test Plan:** `docs/DISCORD_OAUTH_TEST_PLAN.md`
- **AI Development:** `CLAUDE.md`

---

**Questions?** Open an issue on GitHub or check the documentation in `docs/`.

*Last Updated: October 27, 2025*
