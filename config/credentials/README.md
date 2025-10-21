# Rails Credentials - GuildHub

This directory contains environment-specific encrypted credentials for the GuildHub application.

## Files

- `development.yml.enc` - Encrypted development credentials
- `development.key` - Encryption key for development (NEVER commit this!)
- `production.yml.enc` - Encrypted production credentials
- `production.key` - Encryption key for production (NEVER commit this!)

## Security

**IMPORTANT**: The `.key` files are listed in `.gitignore` and should **NEVER** be committed to version control.

- Development keys can be shared with team members via secure channels (1Password, etc.)
- Production keys should only be known to deployment administrators
- Store production keys in your deployment platform's environment variables

## Usage

### Viewing Credentials

```bash
# View development credentials
bin/rails credentials:show --environment development

# View production credentials
bin/rails credentials:show --environment production
```

### Editing Credentials

```bash
# Edit development credentials
bin/rails credentials:edit --environment development

# Edit production credentials
bin/rails credentials:edit --environment production
```

This will open the decrypted credentials in your default editor (set via `EDITOR` environment variable).

## Credential Structure

Both development and production credentials contain:

### Required

- `secret_key_base` - Rails session encryption key (generated with `bin/rails secret`)

### Optional (with placeholders)

- `database` - Database credentials (can also use DATABASE_URL env var)
  - `username`
  - `password`
  - `host`
- `discord` - Discord OAuth configuration
  - `client_id`
  - `client_secret`
  - `bot_token` (for Discord bot integration)
- `redis` - Redis connection URL
  - `url`
- `aws` - AWS S3 configuration (for ActiveStorage)
  - `access_key_id`
  - `secret_access_key`
  - `region`
  - `bucket`
- `sentry_dsn` - Error tracking (Sentry)
- `smtp` - Email configuration (production only)
  - `address`
  - `port`
  - `domain`
  - `user_name`
  - `password`

## Accessing Credentials in Code

```ruby
# Access development credentials
Rails.application.credentials.discord[:client_id]

# Access environment-specific credentials
Rails.application.credentials.database[:password]

# With fallback
Rails.application.credentials.dig(:aws, :access_key_id) || ENV['AWS_ACCESS_KEY_ID']
```

## Setup for New Developers

1. **Get the encryption keys** from a team administrator via secure channel
2. **Place the keys** in the correct locations:
   ```bash
   # Development key
   echo "YOUR_DEVELOPMENT_KEY" > config/credentials/development.key

   # Production key (if needed)
   echo "YOUR_PRODUCTION_KEY" > config/credentials/production.key
   ```
3. **Verify** you can decrypt the credentials:
   ```bash
   bin/rails credentials:show --environment development
   ```

## Rotating Keys

If credentials are compromised:

1. Generate new encryption key: `openssl rand -base64 32 | head -c 32`
2. Save decrypted credentials: `bin/rails credentials:show --environment production > temp.yml`
3. Replace old key with new key in `production.key`
4. Re-encrypt: `EDITOR='cp temp.yml' bin/rails credentials:edit --environment production`
5. Update deployment platform with new key
6. Securely delete `temp.yml`

## Deployment

### Heroku

```bash
heroku config:set RAILS_MASTER_KEY=$(cat config/credentials/production.key) --app guildhub-production
```

### Docker

Add to docker-compose.yml or Dockerfile:

```yaml
environment:
  RAILS_MASTER_KEY: ${RAILS_MASTER_KEY}
```

### Environment Variable

Rails will use `RAILS_MASTER_KEY` environment variable if the `.key` file is not present.

```bash
export RAILS_MASTER_KEY="your_production_key_here"
```

## Troubleshooting

### "Missing encryption key" error

- Ensure the `.key` file exists in `config/credentials/`
- Or set `RAILS_MASTER_KEY` environment variable

### "Couldn't decrypt" error

- The key doesn't match the encrypted file
- Verify you have the correct key from the team administrator

### "Key must be exactly 32 characters" error

- Encryption keys must be exactly 32 bytes
- Generate with: `openssl rand -base64 32 | head -c 32`

## References

- [Rails Guides - Credentials](https://guides.rubyonrails.org/security.html#custom-credentials)
- [Rails API - Encrypted Configuration](https://api.rubyonrails.org/classes/ActiveSupport/EncryptedConfiguration.html)
