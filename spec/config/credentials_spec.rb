# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Credentials Configuration', type: :configuration do
  describe 'environment-specific credentials' do
    it 'has development credentials file' do
      expect(File.exist?(Rails.root.join('config/credentials/development.yml.enc'))).to be true
    end

    it 'has production credentials file' do
      expect(File.exist?(Rails.root.join('config/credentials/production.yml.enc'))).to be true
    end

    # These tests only run locally where .key files exist (not in CI/CD)
    it 'has development encryption key', skip: ENV['CI'].present? do
      expect(File.exist?(Rails.root.join('config/credentials/development.key'))).to be true
    end

    it 'has production encryption key', skip: ENV['CI'].present? do
      expect(File.exist?(Rails.root.join('config/credentials/production.key'))).to be true
    end
  end

  describe 'credential structure' do
    let(:credentials) { Rails.application.credentials }

    # Skip credential content tests in CI/CD or test environment where credentials may not be configured
    it 'has secret_key_base', skip: (ENV['CI'].present? || Rails.env.test?) do
      expect(credentials.secret_key_base).to be_present
      expect(credentials.secret_key_base).to be_a(String)
      expect(credentials.secret_key_base.length).to be >= 128
    end

    it 'has discord configuration structure', skip: (ENV['CI'].present? || Rails.env.test?) do
      discord_config = credentials.discord
      expect(discord_config).to be_a(Hash)
      expect(discord_config).to have_key(:client_id)
      expect(discord_config).to have_key(:client_secret)
      expect(discord_config).to have_key(:bot_token)
    end

    it 'has database configuration structure', skip: (ENV['CI'].present? || Rails.env.test?) do
      database_config = credentials.database
      expect(database_config).to be_a(Hash)
      expect(database_config).to have_key(:username)
      expect(database_config).to have_key(:password)
      expect(database_config).to have_key(:host)
    end

    it 'has redis configuration structure', skip: (ENV['CI'].present? || Rails.env.test?) do
      redis_config = credentials.redis
      expect(redis_config).to be_a(Hash)
      expect(redis_config).to have_key(:url)
    end

    it 'has aws configuration structure', skip: (ENV['CI'].present? || Rails.env.test?) do
      aws_config = credentials.aws
      expect(aws_config).to be_a(Hash)
      expect(aws_config).to have_key(:access_key_id)
      expect(aws_config).to have_key(:secret_access_key)
      expect(aws_config).to have_key(:region)
      expect(aws_config).to have_key(:bucket)
    end
  end

  describe 'security checks' do
    it 'gitignore includes encryption keys' do
      gitignore = File.read(Rails.root.join('.gitignore'))
      expect(gitignore).to include('/config/master.key')
      expect(gitignore).to include('/config/credentials/*.key')
    end

    it 'does not commit encryption keys' do
      # Verify .key files are not in git
      key_files = Dir.glob(Rails.root.join('config/credentials/*.key'))
      key_files.each do |key_file|
        git_tracked = system("git ls-files --error-unmatch #{key_file} 2>/dev/null")
        expect(git_tracked).to be_falsey, "#{key_file} should not be tracked by git"
      end
    end

    it 'encrypted credential files are tracked' do
      # Verify .yml.enc files ARE in git
      enc_files = Dir.glob(Rails.root.join('config/credentials/*.yml.enc'))
      expect(enc_files).not_to be_empty
      enc_files.each do |enc_file|
        git_tracked = system("git ls-files --error-unmatch #{enc_file} 2>/dev/null")
        expect(git_tracked).to be_truthy, "#{enc_file} should be tracked by git"
      end
    end
  end
end
