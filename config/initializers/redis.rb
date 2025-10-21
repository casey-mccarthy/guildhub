# Redis initializer for GuildHub
# Provides a global Redis connection for custom usage beyond Rails cache/cable

# Load Redis configuration
redis_config = Rails.application.config_for(:redis)

# Create a global Redis connection pool
# This can be used for custom Redis operations outside of Rails cache/ActionCable
Redis.current = Redis.new(
  url: redis_config["url"],
  timeout: redis_config["timeout"] || 5,
  reconnect_attempts: redis_config["reconnect_attempts"] || 3
)

# Log Redis connection on startup
Rails.application.config.after_initialize do
  begin
    Redis.current.ping
    Rails.logger.info "✅ Redis connected: #{redis_config['url']}"
  rescue Redis::CannotConnectError => e
    Rails.logger.error "❌ Redis connection failed: #{e.message}"
    # Don't crash the app if Redis is unavailable
    # Cache operations will gracefully degrade
  end
end
