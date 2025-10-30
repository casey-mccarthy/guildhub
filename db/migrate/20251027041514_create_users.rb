class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :discord_id, null: false
      t.string :discord_username
      t.string :discord_avatar_url
      t.string :email
      t.string :encrypted_password
      t.boolean :admin, default: false, null: false

      t.timestamps
    end

    add_index :users, :discord_id, unique: true
    add_index :users, :email
  end
end
