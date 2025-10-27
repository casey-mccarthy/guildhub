# Discord Application Setup Guide

This guide walks you through setting up Discord OAuth authentication for GuildHub.

## Overview

GuildHub uses Discord OAuth as the primary authentication method for guild members. This allows users to "Login with Discord" without needing separate passwords.

**Note:** This is OAuth authentication only (not a Discord bot). The actual Discord bot with slash commands will be set up later in Phase 3.

---

## Step 1: Create Discord Application

### 1.1 Go to Discord Developer Portal

Visit: **https://discord.com/developers/applications**

- Log in with your Discord account
- Click **"New Application"** button (top right)

### 1.2 Create Application

- **Application Name:** `GuildHub` (or `GuildHub Dev` for development)
- **Description:** "DKP management system for Project 1999 EverQuest guilds"
- Agree to Discord Developer Terms of Service
- Click **"Create"**

### 1.3 Configure General Information

On the **General Information** tab:

- **Name:** GuildHub
- **Description:** Modern DKP management for P99 EverQuest guilds
- **Icon:** (Optional) Upload GuildHub logo
- **Tags:** Select `Game Utilities` or similar
- Click **"Save Changes"**

---

## Step 2: Configure OAuth2

### 2.1 Go to OAuth2 Settings

- Click **"OAuth2"** in the left sidebar
- Click **"General"** under OAuth2

### 2.2 Copy Credentials

**Important:** You'll need these credentials for Rails configuration.

1. **Client ID**
   - Copy the Client ID (public identifier)
   - Example: `1234567890123456789`

2. **Client Secret**
   - Click **"Reset Secret"** (or **"Copy"** if already generated)
   - **⚠️ IMPORTANT:** Save this immediately - you won't see it again!
   - Example: `abcdefghijklmnopqrstuvwxyz123456`

### 2.3 Set Redirect URIs

Click **"Add Redirect"** and add these URLs:

**Development:**
```
http://localhost:3000/auth/discord/callback
```

**Production (when deployed):**
```
https://yourdomain.com/auth/discord/callback
https://guildhub.herokuapp.com/auth/discord/callback
```

**Staging (optional):**
```
https://staging.yourdomain.com/auth/discord/callback
```

Click **"Save Changes"**

### 2.4 Configure OAuth2 Scopes (Later Step)

You'll configure scopes when setting up OmniAuth in Rails:
- `identify` - Read user info (username, ID, avatar)
- `email` - Read user email address

---

## Step 3: Bot Configuration (Optional - For Future)

**Skip this for now** - We'll set this up in Phase 3 (Epic 10).

For reference, when you're ready to add the Discord bot:
- Go to **"Bot"** tab in left sidebar
- Click **"Add Bot"**
- Configure bot token and permissions
- Enable required intents

---

## Step 4: Store Credentials in Rails

### 4.1 Edit Rails Credentials

Open Rails encrypted credentials:

```bash
bin/rails credentials:edit
```

### 4.2 Add Discord Credentials

Add the following structure:

```yaml
discord:
  client_id: YOUR_CLIENT_ID_HERE
  client_secret: YOUR_CLIENT_SECRET_HERE
  # Bot token (for later in Phase 3)
  # bot_token: YOUR_BOT_TOKEN_HERE
```

**Example:**
```yaml
discord:
  client_id: "1234567890123456789"
  client_secret: "abcdefghijklmnopqrstuvwxyz123456"
```

Save and close the editor (`:wq` in vim, `Ctrl+X` in nano).

### 4.3 Verify Credentials

Test that credentials are accessible:

```bash
bin/rails console
```

```ruby
Rails.application.credentials.discord.client_id
# => "1234567890123456789"

Rails.application.credentials.discord.client_secret
# => "abcdefghijklmnopqrstuvwxyz123456"
```

Type `exit` to quit the console.

---

## Step 5: Security Best Practices

### ✅ DO:
- Keep your Client Secret private (never commit to git)
- Use environment variables for production
- Rotate secrets if compromised
- Use different applications for development vs production
- Regularly audit authorized applications

### ❌ DON'T:
- Never commit credentials to git
- Never share your Client Secret publicly
- Don't use production credentials in development
- Don't hardcode credentials in source code

---

## Troubleshooting

### "Invalid Redirect URI" Error

**Problem:** OAuth redirect fails with error about invalid redirect URI.

**Solution:**
- Verify the redirect URI in Discord matches exactly: `http://localhost:3000/auth/discord/callback`
- Check for trailing slashes (should NOT have one)
- Ensure protocol matches (http vs https)

### "Invalid Client" Error

**Problem:** OAuth fails with "invalid client" error.

**Solution:**
- Verify Client ID is correct in Rails credentials
- Verify Client Secret is correct (regenerate if needed)
- Check that credentials are not expired

### Credentials Not Loading

**Problem:** `Rails.application.credentials.discord` returns `nil`

**Solution:**
- Ensure credentials file was saved properly
- Verify master key exists: `config/master.key`
- Try editing credentials again: `bin/rails credentials:edit`
- Check syntax (valid YAML format)

---

## Next Steps

After completing this setup:

1. ✅ **T2.1.1:** Discord app created ← You are here
2. ⏭️ **T2.1.2:** Configure OmniAuth Discord (next task)
3. ⏭️ **T2.1.3:** Create Users migration and model
4. ⏭️ **T2.1.4:** Implement OmniAuth callback controller
5. ⏭️ **T2.1.5:** Add Discord login button

---

## References

- **Discord Developer Portal:** https://discord.com/developers/applications
- **Discord OAuth2 Docs:** https://discord.com/developers/docs/topics/oauth2
- **Rails Credentials Guide:** https://guides.rubyonrails.org/security.html#custom-credentials
- **OmniAuth Discord:** https://github.com/wingrunr21/omniauth-discord

---

**Questions?** Check the [DEVELOPMENT.md](../DEVELOPMENT.md) guide or ask in GitHub Discussions.

*Last Updated: October 27, 2025*
