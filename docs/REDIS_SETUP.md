# Redis Setup - GuildHub

This document describes the Redis configuration for the GuildHub application.

## Overview

Redis is used for:
- **Caching** - Application-level caching (DKP standings, guild dashboards)
- **ActionCable** - WebSocket connections for real-time features
- **Solid Queue** - Background job processing (Rails 8 default)
- **Session Store** - (Future) User sessions

## Configuration Files

### 1. `config/redis.yml`
Central Redis configuration for all environments.

```yaml
development:
  url: redis://localhost:6379/0

test:
  url: redis://localhost:6379/1  # Separate database

production:
  url: <%= ENV.fetch("REDIS_URL") %>
```

### 2. `config/environments/development.rb`
Cache store configuration:

```ruby
config.cache_store = :redis_cache_store, {
  url: ENV.fetch("REDIS_URL") { "redis://localhost:6379/0" },
  namespace: "guildhub_development",
  expires_in: 90.minutes
}
```

### 3. `config/cable.yml`
ActionCable adapter configuration:

```yaml
development:
  adapter: redis
  url: redis://localhost:6379/0
```

### 4. `config/initializers/redis.rb`
Global Redis connection for custom usage:

```ruby
Redis.current = Redis.new(url: redis_config["url"])
```

## Docker Setup

Redis is configured in `docker-compose.yml`:

```yaml
redis:
  image: redis:7-alpine
  ports:
    - "6379:6379"
  volumes:
    - redis_data:/data
```

## Usage

### Starting Redis

**With Docker:**
```bash
docker compose up -d redis
```

**Standalone (macOS):**
```bash
brew install redis
brew services start redis
```

**Standalone (Linux):**
```bash
sudo apt install redis-server
sudo systemctl start redis
```

### Testing Redis Connection

```bash
# Run the test script
bin/test_redis

# Or manually in Rails console
bin/rails console
> Redis.current.ping
=> "PONG"

> Rails.cache.write("test", "value")
=> true

> Rails.cache.read("test")
=> "value"
```

### Monitoring Redis

**Check Redis status:**
```bash
docker compose exec redis redis-cli ping
# => PONG

docker compose exec redis redis-cli info
```

**View cached keys:**
```bash
docker compose exec redis redis-cli
> KEYS guildhub_development:*
> GET guildhub_development:character/123/dkp_balance
```

**Monitor commands in real-time:**
```bash
docker compose exec redis redis-cli monitor
```

## Cache Namespaces

Each environment uses a different namespace to prevent collisions:

- **Development:** `guildhub_development`
- **Test:** `guildhub_test`
- **Production:** `guildhub_production`

## Cache Keys

### DKP Balances
```
guildhub_production:character/{id}/dkp_balance
```
- **Expires:** 5 minutes
- **Invalidated on:** raid attendance, item award, adjustment

### DKP Standings
```
guildhub_production:guild/{id}/standings
```
- **Expires:** 5 minutes
- **Invalidated on:** any DKP change

### Guild Dashboard
```
guildhub_production:guild/{id}/dashboard
```
- **Expires:** 15 minutes
- **Invalidated on:** announcement, raid, item award

## Environment Variables

### Development
```bash
export REDIS_URL="redis://localhost:6379/0"
```

### Docker
Already configured in `docker-compose.yml`:
```yaml
environment:
  REDIS_URL: redis://redis:6379/0
```

### Production
Set on your deployment platform:

**Heroku:**
```bash
heroku addons:create heroku-redis:mini
# REDIS_URL is automatically set
```

**Railway:**
```bash
# Add Redis service in Railway dashboard
# Copy REDIS_URL to environment variables
```

**Self-hosted:**
```bash
export REDIS_URL="redis://your-redis-host:6379/0"
# or with authentication
export REDIS_URL="redis://:password@your-redis-host:6379/0"
```

## Performance Tips

### 1. Cache Key Design
Use hierarchical keys for easy invalidation:
```ruby
# Good
Rails.cache.fetch("guild/#{guild.id}/standings") { ... }

# Bad
Rails.cache.fetch("standings_#{guild.id}") { ... }
```

### 2. Set Appropriate TTLs
```ruby
# Frequently changing data (DKP balances)
expires_in: 5.minutes

# Slow-changing data (guild info)
expires_in: 1.hour

# Static data (class/race lists)
expires_in: 1.day
```

### 3. Use Fragment Caching
```erb
<% cache ["guild_dashboard", @guild] do %>
  <%= render @guild.dashboard_widgets %>
<% end %>
```

## Troubleshooting

### Connection Refused
```
Error: Redis::CannotConnectError - Error connecting to Redis on localhost:6379
```

**Solution:**
```bash
# Check if Redis is running
docker compose ps redis

# Start Redis
docker compose up -d redis

# Check logs
docker compose logs redis
```

### Wrong Database
```
Error: Data appearing in wrong environment
```

**Solution:**
- Check `REDIS_URL` environment variable
- Verify database number (development=0, test=1)
- Clear the database: `Redis.current.flushdb`

### Memory Issues
```
Error: OOM command not allowed when used memory > 'maxmemory'
```

**Solution:**
```bash
# Check memory usage
docker compose exec redis redis-cli info memory

# Set eviction policy in docker-compose.yml:
command: redis-server --maxmemory 256mb --maxmemory-policy allkeys-lru
```

### Performance Issues
```
Slow cache reads/writes
```

**Solution:**
- Check network latency to Redis
- Monitor slow queries: `docker compose exec redis redis-cli slowlog get 10`
- Consider connection pooling
- Review cache key complexity

## Security

### Production Checklist
- [ ] Use strong passwords: `requirepass your-strong-password`
- [ ] Enable SSL/TLS for connections
- [ ] Restrict network access (firewall rules)
- [ ] Use separate Redis instances per environment
- [ ] Regular backups (if using Redis for persistence)
- [ ] Monitor for suspicious activity

### Authentication
```yaml
# config/redis.yml (production)
production:
  url: <%= ENV.fetch("REDIS_URL") { "redis://:password@host:6379/0" } %>
  ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE }
```

## Monitoring & Metrics

### Key Metrics to Track
- **Hit Rate:** `(hits / (hits + misses)) * 100`
- **Memory Usage:** Used memory vs. max memory
- **Connected Clients:** Current connections
- **Commands/sec:** Throughput
- **Evicted Keys:** Keys removed due to memory pressure

### Recommended Tools
- **RedisInsight** - GUI for Redis
- **Redis CLI** - Built-in monitoring
- **Grafana + Prometheus** - Metrics dashboards
- **New Relic / DataDog** - APM integration

## References

- [Redis Documentation](https://redis.io/docs/)
- [Rails Caching Guide](https://guides.rubyonrails.org/caching_with_rails.html)
- [ActionCable Redis Adapter](https://guides.rubyonrails.org/action_cable_overview.html#redis)
- [Redis Best Practices](https://redis.io/docs/manual/patterns/)

---

**Last Updated:** October 21, 2025
**Redis Version:** 7.x
**Rails Version:** 8.0+
