class CreateAccessTokens < ActiveRecord::Migration[7.0]
  def change
    create_table :access_tokens do |t|
      t.string :token
      t.string :scope
      t.integer :expires_in
      t.datetime :revoked_at, null: true, default: nil
      t.references :user, type: :uuid, null: false, foreign_key: true

      t.timestamps

      t.index :token, unique: true
    end
  end
end
