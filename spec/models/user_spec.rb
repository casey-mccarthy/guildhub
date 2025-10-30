# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    let(:user) { User.new(email: 'test@example.com', password: 'password123') }

    it 'is valid with valid attributes' do
      expect(user).to be_valid
    end

    it 'requires an email' do
      user.email = nil
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("can't be blank")
    end

    it 'requires a unique email (case insensitive)' do
      User.create!(email: 'TEST@example.com', password: 'password123')
      duplicate = User.new(email: 'test@example.com', password: 'password123')
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:email]).to include('has already been taken')
    end

    it 'requires a unique username when present (case insensitive)' do
      User.create!(email: 'user1@example.com', username: 'TestUser', password: 'password123')
      duplicate = User.new(email: 'user2@example.com', username: 'testuser', password: 'password123')
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:username]).to include('has already been taken')
    end

    it 'allows nil username' do
      user.username = nil
      expect(user).to be_valid
    end

    context 'for password authentication' do
      it 'requires encrypted_password for password auth users' do
        user = User.new(email: 'test@example.com', provider: nil)
        user.valid?
        expect(user.errors[:encrypted_password]).to include("can't be blank")
      end
    end

    context 'for OAuth authentication' do
      it 'requires unique uid scoped to provider' do
        User.create!(email: 'oauth1@example.com', provider: 'discord', uid: '12345')
        duplicate = User.new(email: 'oauth2@example.com', provider: 'discord', uid: '12345')
        expect(duplicate).not_to be_valid
        expect(duplicate.errors[:uid]).to include('has already been taken')
      end

      it 'allows same uid for different providers' do
        User.create!(email: 'oauth1@example.com', provider: 'discord', uid: '12345')
        different_provider = User.new(email: 'oauth2@example.com', provider: 'google', uid: '12345')
        expect(different_provider).to be_valid
      end
    end
  end

  describe 'callbacks' do
    describe '#normalize_email' do
      it 'downcases email before validation' do
        user = User.create!(email: 'TEST@EXAMPLE.COM', password: 'password123')
        expect(user.email).to eq('test@example.com')
      end

      it 'strips whitespace from email' do
        user = User.create!(email: '  test@example.com  ', password: 'password123')
        expect(user.email).to eq('test@example.com')
      end

      it 'handles nil email gracefully' do
        user = User.new(email: nil)
        expect { user.valid? }.not_to raise_error
      end
    end

    describe '#set_default_username' do
      it 'sets username from email prefix on create' do
        user = User.create!(email: 'johndoe@example.com', password: 'password123')
        expect(user.username).to eq('johndoe')
      end

      it 'does not override provided username' do
        user = User.create!(email: 'johndoe@example.com', username: 'customname', password: 'password123')
        expect(user.username).to eq('customname')
      end

      it 'only runs on new records' do
        user = User.create!(email: 'johndoe@example.com', password: 'password123')
        original_username = user.username
        user.update!(email: 'newemail@example.com')
        expect(user.username).to eq(original_username)
      end
    end
  end

  describe 'scopes' do
    before do
      @admin = User.create!(email: 'admin@example.com', password: 'password123', admin: true)
      @member = User.create!(email: 'member@example.com', password: 'password123', admin: false)
      @password_user = User.create!(email: 'password@example.com', password: 'password123', provider: nil)
      @oauth_user = User.create!(email: 'oauth@example.com', provider: 'discord', uid: '123')
    end

    describe '.admins' do
      it 'returns only admin users' do
        expect(User.admins).to include(@admin)
        expect(User.admins).not_to include(@member)
      end
    end

    describe '.members' do
      it 'returns only non-admin users' do
        expect(User.members).to include(@member)
        expect(User.members).not_to include(@admin)
      end
    end

    describe '.password_users' do
      it 'returns only password authentication users' do
        expect(User.password_users).to include(@password_user)
        expect(User.password_users).not_to include(@oauth_user)
      end
    end

    describe '.oauth_users' do
      it 'returns only OAuth users' do
        expect(User.oauth_users).to include(@oauth_user)
        expect(User.oauth_users).not_to include(@password_user)
      end
    end
  end

  describe 'instance methods' do
    describe '#display_name' do
      it 'returns username when present' do
        user = User.new(username: 'cooluser', email: 'test@example.com')
        expect(user.display_name).to eq('cooluser')
      end

      it 'returns email prefix when username is blank' do
        user = User.new(username: '', email: 'johndoe@example.com')
        expect(user.display_name).to eq('johndoe')
      end

      it 'returns email prefix when username is nil' do
        user = User.new(username: nil, email: 'johndoe@example.com')
        expect(user.display_name).to eq('johndoe')
      end

      it 'returns fallback when both username and email prefix are unavailable' do
        user = User.create!(email: 'test@example.com', password: 'password123')
        user.username = nil
        user.email = '@example.com'
        expect(user.display_name).to eq("User ##{user.id}")
      end
    end

    describe '#password_auth?' do
      it 'returns true when provider is nil' do
        user = User.new(provider: nil)
        expect(user.password_auth?).to be true
      end

      it 'returns false when provider is present' do
        user = User.new(provider: 'discord')
        expect(user.password_auth?).to be false
      end
    end

    describe '#oauth_auth?' do
      it 'returns true when provider is present' do
        user = User.new(provider: 'discord')
        expect(user.oauth_auth?).to be true
      end

      it 'returns false when provider is nil' do
        user = User.new(provider: nil)
        expect(user.oauth_auth?).to be false
      end
    end

    describe '#admin?' do
      it 'returns true when admin flag is true' do
        user = User.new(admin: true)
        expect(user.admin?).to be true
      end

      it 'returns false when admin flag is false' do
        user = User.new(admin: false)
        expect(user.admin?).to be false
      end
    end

    describe '#password_required?' do
      context 'for password auth users' do
        it 'returns true when encrypted_password is blank' do
          user = User.new(provider: nil, encrypted_password: '')
          expect(user.password_required?).to be true
        end

        it 'returns true when password is present' do
          user = User.new(provider: nil, encrypted_password: 'encrypted', password: 'newpass')
          expect(user.password_required?).to be true
        end

        it 'returns false when encrypted_password exists and password is blank' do
          user = User.new(provider: nil, encrypted_password: 'encrypted', password: nil)
          expect(user.password_required?).to be false
        end
      end

      context 'for OAuth users' do
        it 'returns false for OAuth users' do
          user = User.new(provider: 'discord', encrypted_password: '')
          expect(user.password_required?).to be false
        end
      end
    end
  end

  describe 'Devise integration' do
    it 'includes database_authenticatable module' do
      expect(User.devise_modules).to include(:database_authenticatable)
    end

    it 'includes registerable module' do
      expect(User.devise_modules).to include(:registerable)
    end

    it 'includes recoverable module' do
      expect(User.devise_modules).to include(:recoverable)
    end

    it 'includes rememberable module' do
      expect(User.devise_modules).to include(:rememberable)
    end

    it 'includes validatable module' do
      expect(User.devise_modules).to include(:validatable)
    end

    it 'includes trackable module' do
      expect(User.devise_modules).to include(:trackable)
    end
  end
end
