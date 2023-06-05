class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users, id: :uuid do |t|
      t.string :name, limit: 64, null: false
      t.string :email, limit: 128, null: false
      t.string :password_digest, null: false

      t.timestamps

      t.index :email, unique: true
    end
  end
end
