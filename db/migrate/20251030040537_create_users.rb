class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      ## Core authentication (works for both password and OAuth)
      t.string :email, null: false
      t.string :username

      ## Devise password authentication
      t.string :encrypted_password # Nullable - not needed for OAuth users

      ## OAuth fields (for future Discord/other OAuth providers)
      # These are nullable so password users don't need them
      t.string :provider # e.g., 'discord', 'google', nil for password auth
      t.string :uid # Provider's user ID (e.g., Discord snowflake)
      t.string :avatar_url # OAuth provider's avatar URL

      ## Devise trackable (optional, useful for security)
      t.integer :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string :current_sign_in_ip
      t.string :last_sign_in_ip

      ## Authorization
      t.boolean :admin, default: false, null: false

      t.timestamps
    end

    # Indexes
    add_index :users, :email, unique: true
    add_index :users, :username
    add_index :users, [ :provider, :uid ], unique: true # For OAuth uniqueness
  end
end
