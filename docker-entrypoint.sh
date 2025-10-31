#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== GuildHub Docker Entrypoint ===${NC}"

# Wait for PostgreSQL to be ready
echo -e "${YELLOW}Waiting for PostgreSQL...${NC}"
until pg_isready -h db -U postgres; do
  echo -e "${YELLOW}PostgreSQL is unavailable - sleeping${NC}"
  sleep 1
done
echo -e "${GREEN}PostgreSQL is up!${NC}"

# Wait for Redis to be ready (using nc instead of redis-cli)
echo -e "${YELLOW}Waiting for Redis...${NC}"
until nc -z redis 6379; do
  echo -e "${YELLOW}Redis is unavailable - sleeping${NC}"
  sleep 1
done
echo -e "${GREEN}Redis is up!${NC}"

# Create database if it doesn't exist
echo -e "${YELLOW}Ensuring database exists...${NC}"
bundle exec rails db:create 2>/dev/null || echo -e "${GREEN}Database already exists${NC}"

# Run migrations
echo -e "${YELLOW}Running database migrations...${NC}"
bundle exec rails db:migrate

# Check if we're in test mode and need to prepare test database
if [ "$RAILS_ENV" = "test" ]; then
  echo -e "${YELLOW}Preparing test database...${NC}"
  bundle exec rails db:test:prepare
fi

# Seed database if SEED=true environment variable is set
if [ "$SEED" = "true" ]; then
  echo -e "${YELLOW}Seeding database...${NC}"
  bundle exec rails db:seed
fi

# Remove server PID file if it exists (prevents "server already running" errors)
if [ -f tmp/pids/server.pid ]; then
  echo -e "${YELLOW}Removing old server PID file...${NC}"
  rm -f tmp/pids/server.pid
fi

echo -e "${GREEN}=== Setup Complete! Starting Rails Server ===${NC}"
echo ""

# Execute the main command (starts Rails server)
exec "$@"
