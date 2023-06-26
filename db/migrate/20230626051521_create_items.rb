class CreateItems < ActiveRecord::Migration[7.0]
  def change
    create_table :items, id: :uuid do |t|
      t.string :name, null: false
      t.text :description
      t.references :user, type: :uuid, null: false, foreign_key: true

      t.timestamps

      t.index %i[name user_id], unique: true
    end
  end
end
