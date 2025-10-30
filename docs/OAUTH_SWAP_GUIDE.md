# OAuth Swap Strategy - Discord Authentication

This guide explains how to swap from username/password authentication to Discord OAuth when ready for production.

## Current State (Development)

**Authentication Method:** Username/Password via Devise
**Why:** Allows offline local development without OAuth dependency
**Database Schema:** Already OAuth-ready (no migration needed!)

## Schema Design (Flexible)

The `users` table supports **both** authentication methods:

```ruby
# Password authentication fields
- email (required for both methods)
- encrypted_password (nullable - not needed for OAuth)

# OAuth authentication fields
- provider (nullable - e.g., 'discord', 'google')
- uid (nullable - OAuth provider's user ID)
- avatar_url (nullable - OAuth avatar)

# Shared fields
- username (display name for both methods)
- admin (authorization)
```

**Key Design Decision:** All auth-specific fields are nullable, so users can authenticate via password OR OAuth without migration.

---

## Swap to Discord OAuth (When Ready for MVP)

### Step 1: Add Discord OAuth Gem (Already Installed!)

The `omniauth-discord` gem is already in the Gemfile. If not, add:

```ruby
# Gemfile
gem 'omniauth-discord'
gem 'omniauth-rails_csrf_protection'
```

### Step 2: Configure Discord Application

1. Go to https://discord.com/developers/applications
2. Create new application: "GuildHub"
3. Go to OAuth2 → General:
   - Add Redirect URI: `http://localhost:3000/users/auth/discord/callback` (dev)
   - Add Redirect URI: `https://yourdomain.com/users/auth/discord/callback` (prod)
4. Copy Client ID and Client Secret

### Step 3: Add Discord Credentials

```bash
# Edit credentials
EDITOR="code --wait" bin/rails credentials:edit

# Add:
discord:
  client_id: YOUR_DISCORD_CLIENT_ID_HERE
  client_secret: YOUR_DISCORD_CLIENT_SECRET_HERE
```

### Step 4: Configure Devise for OmniAuth

Edit `config/initializers/devise.rb` and add:

```ruby
# config/initializers/devise.rb
Devise.setup do |config|
  # ... existing config ...

  # Add Discord OAuth
  config.omniauth :discord,
                  Rails.application.credentials.dig(:discord, :client_id),
                  Rails.application.credentials.dig(:discord, :client_secret),
                  scope: 'identify email',
                  prompt: 'none'
end
```

### Step 5: Update Routes

Uncomment the OAuth routes in `config/routes.rb`:

```ruby
# config/routes.rb
Rails.application.routes.draw do
  # BEFORE (password only):
  # devise_for :users

  # AFTER (with OAuth):
  devise_for :users, controllers: {
    omniauth_callbacks: 'users/omniauth_callbacks'
  }

  # ... rest of routes
end
```

### Step 6: Uncomment OAuth Method in User Model

In `app/models/user.rb`, uncomment the `from_omniauth` method:

```ruby
# app/models/user.rb
class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :trackable,
         :omniauthable, omniauth_providers: [:discord]  # Add this line

  # Uncomment this method:
  def self.from_omniauth(auth_hash)
    where(provider: auth_hash['provider'], uid: auth_hash['uid']).first_or_create do |user|
      user.email = auth_hash['info']['email']
      user.username = auth_hash['info']['name'] || auth_hash['info']['nickname']
      user.avatar_url = auth_hash['info']['image']
      user.password = Devise.friendly_token[0, 20] # Random password (not used)
    end
  end

  # ... rest of model
end
```

### Step 7: Create OmniAuth Callback Controller

```ruby
# app/controllers/users/omniauth_callbacks_controller.rb
class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def discord
    @user = User.from_omniauth(request.env['omniauth.auth'])

    if @user.persisted?
      sign_in_and_redirect @user, event: :authentication
      set_flash_message(:notice, :success, kind: 'Discord') if is_navigational_format?
    else
      session['devise.discord_data'] = request.env['omniauth.auth'].except(:extra)
      redirect_to new_user_registration_url, alert: @user.errors.full_messages.join("\n")
    end
  end

  def failure
    redirect_to root_path, alert: 'Authentication failed. Please try again.'
  end
end
```

### Step 8: Update Views

Add Discord login button to `app/views/devise/sessions/new.html.erb`:

```erb
<div class="text-center">
  <%= button_to "Sign in with Discord",
                user_discord_omniauth_authorize_path,
                method: :post,
                data: { turbo: false },
                class: "btn btn-discord" %>
</div>
```

### Step 9: Test OAuth Flow

1. Start server: `bin/dev`
2. Visit: `http://localhost:3000/users/sign_in`
3. Click "Sign in with Discord"
4. Authorize on Discord
5. You should be redirected back and signed in!

---

## Migration Strategy (Existing Users)

If you have existing password users when swapping to OAuth:

### Option A: Dual Authentication (Recommended)

Keep both methods enabled:
- Existing users can still log in with password
- New users sign up via Discord
- Users can link Discord to existing account

**Implementation:**
```ruby
# app/models/user.rb
def self.from_omniauth(auth_hash)
  # Try to find by OAuth
  user = where(provider: auth_hash['provider'], uid: auth_hash['uid']).first

  # If not found, try to find by email and link accounts
  user ||= find_by(email: auth_hash['info']['email'])

  if user
    # Update OAuth info for existing user
    user.update(
      provider: auth_hash['provider'],
      uid: auth_hash['uid'],
      avatar_url: auth_hash['info']['image']
    )
  else
    # Create new OAuth user
    user = create(
      email: auth_hash['info']['email'],
      username: auth_hash['info']['name'],
      provider: auth_hash['provider'],
      uid: auth_hash['uid'],
      avatar_url: auth_hash['info']['image'],
      password: Devise.friendly_token[0, 20]
    )
  end

  user
end
```

### Option B: OAuth Only (Simple)

Disable password authentication entirely:

```ruby
# app/models/user.rb
devise :omniauthable, :trackable, omniauth_providers: [:discord]
# Remove: :database_authenticatable, :registerable, :recoverable
```

Force existing users to link Discord:
1. Send email notification
2. Provide Discord link flow
3. Disable password login after grace period

---

## Rollback Plan

If OAuth causes issues, rollback is easy:

1. Comment out OAuth config in `devise.rb`
2. Revert routes to password-only
3. Comment out `:omniauthable` in User model
4. Restart server

**No database migration needed!** OAuth fields remain in database but unused.

---

## Testing OAuth Locally

### Mock OAuth in Tests

```ruby
# spec/rails_helper.rb
OmniAuth.config.test_mode = true
OmniAuth.config.mock_auth[:discord] = OmniAuth::AuthHash.new({
  provider: 'discord',
  uid: '123456789',
  info: {
    name: 'TestUser',
    email: 'test@example.com',
    image: 'https://cdn.discordapp.com/avatars/123/abc.png'
  }
})
```

### Test OAuth Callback

```ruby
# spec/requests/users/omniauth_callbacks_spec.rb
require 'rails_helper'

RSpec.describe 'Discord OAuth', type: :request do
  before do
    Rails.application.env_config['devise.mapping'] = Devise.mappings[:user]
    Rails.application.env_config['omniauth.auth'] = OmniAuth.config.mock_auth[:discord]
  end

  it 'signs in user via Discord' do
    expect {
      post user_discord_omniauth_callback_path
    }.to change(User, :count).by(1)

    expect(response).to redirect_to(root_path)
    user = User.last
    expect(user.provider).to eq('discord')
    expect(user.email).to eq('test@example.com')
  end
end
```

---

## Comparison: Password vs OAuth

| Feature | Password Auth | Discord OAuth |
|---------|--------------|---------------|
| **Offline dev** | ✅ Yes | ❌ No (needs Discord) |
| **User friction** | ⚠️ Signup form | ✅ One-click |
| **Security** | ⚠️ Password management | ✅ No passwords |
| **P99 integration** | ❌ No | ✅ Yes (Discord is standard) |
| **Testing** | ✅ Easy | ⚠️ Needs mocking |
| **Maintenance** | ⚠️ Password resets, etc. | ✅ Handled by Discord |

---

## Timeline Recommendation

- **Phase 1 (Now):** Password auth for local dev
- **Phase 2:** Add OAuth alongside password (dual auth)
- **Phase 3 (MVP):** Make OAuth primary, password optional
- **Phase 4 (Production):** OAuth only for new users

---

## Resources

- [Devise OmniAuth Guide](https://github.com/heartcombo/devise/wiki/OmniAuth:-Overview)
- [OmniAuth Discord](https://github.com/adaoraul/omniauth-discord)
- [Discord OAuth Documentation](https://discord.com/developers/docs/topics/oauth2)
- [Project CLAUDE.md](../CLAUDE.md) - GuildHub development guide

---

**Last Updated:** 2025-10-30
**Status:** Password auth implemented, OAuth swap ready
**Migration Required:** ❌ No (schema supports both)
