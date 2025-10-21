# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Redis Configuration', type: :configuration do
  describe 'redis configuration file' do
    it 'exists' do
      expect(File.exist?(Rails.root.join('config/redis.yml'))).to be true
    end

    it 'has valid YAML structure' do
      config = YAML.load_file(Rails.root.join('config/redis.yml'), aliases: true)
      expect(config).to be_a(Hash)
      expect(config).to have_key('development')
      expect(config).to have_key('test')
      expect(config).to have_key('production')
    end

    it 'configures different databases for environments' do
      config = Rails.application.config_for(:redis)
      expect(config['url']).to be_present
    end
  end

  describe 'Redis connection' do
    it 'connects to Redis successfully' do
      expect { Redis.current.ping }.not_to raise_error
      expect(Redis.current.ping).to eq('PONG')
    end

    it 'has Redis.current configured' do
      expect(Redis.current).to be_a(Redis)
    end

    it 'can write and read from Redis' do
      test_key = 'test:rspec:connection'
      test_value = 'testing-redis-connection'

      Redis.current.set(test_key, test_value)
      expect(Redis.current.get(test_key)).to eq(test_value)

      # Cleanup
      Redis.current.del(test_key)
    end
  end

  describe 'Rails cache store' do
    it 'uses Redis cache store' do
      expect(Rails.cache.class.name).to include('RedisCacheStore')
    end

    it 'can write to cache' do
      test_key = 'test_cache_key'
      test_value = { data: 'test_value' }

      Rails.cache.write(test_key, test_value)
      expect(Rails.cache.read(test_key)).to eq(test_value)

      # Cleanup
      Rails.cache.delete(test_key)
    end

    it 'can delete from cache' do
      test_key = 'test_cache_delete'
      Rails.cache.write(test_key, 'value')
      Rails.cache.delete(test_key)
      expect(Rails.cache.read(test_key)).to be_nil
    end

    it 'respects cache namespacing' do
      cache_config = Rails.configuration.cache_store
      if cache_config.is_a?(Array) && cache_config.last.is_a?(Hash)
        expect(cache_config.last[:namespace]).to be_present
        expect(cache_config.last[:namespace]).to include(Rails.env)
      end
    end
  end

  describe 'ActionCable configuration' do
    it 'uses Redis adapter' do
      cable_config = Rails.application.config_for(:cable)
      expect(cable_config['adapter']).to eq('redis')
    end

    it 'has valid Redis URL' do
      cable_config = Rails.application.config_for(:cable)
      expect(cable_config['url']).to be_present
      expect(cable_config['url']).to match(/^redis:\/\//)
    end

    it 'has channel prefix configured' do
      cable_config = Rails.application.config_for(:cable)
      expect(cable_config['channel_prefix']).to be_present
      expect(cable_config['channel_prefix']).to include(Rails.env)
    end
  end

  describe 'Redis initializer' do
    it 'initializer file exists' do
      expect(File.exist?(Rails.root.join('config/initializers/redis.rb'))).to be true
    end

    it 'logs Redis connection status' do
      # This test ensures the initializer runs without errors
      # The actual logging is captured in Rails logs
      expect(Redis.current.connected?).to be true
    end
  end

  describe 'environment-specific configuration' do
    it 'uses different Redis databases per environment' do
      config = Rails.application.config_for(:redis)
      url = config['url']

      if Rails.env.test?
        # Test environment should use database 1
        expect(url).to match(/\/1\z/)
      elsif Rails.env.development?
        # Development environment should use database 0
        expect(url).to match(/\/0\z/)
      end
    end

    it 'has proper timeout configured' do
      config = Rails.application.config_for(:redis)
      expect(config['timeout']).to be_present
      expect(config['timeout']).to be_a(Integer)
      expect(config['timeout']).to be > 0
    end

    it 'has reconnect attempts configured' do
      config = Rails.application.config_for(:redis)
      expect(config['reconnect_attempts']).to be_present
      expect(config['reconnect_attempts']).to be_a(Integer)
      expect(config['reconnect_attempts']).to be >= 3
    end
  end
end
