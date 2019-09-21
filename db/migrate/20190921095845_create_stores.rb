class CreateStores < ActiveRecord::Migration[5.0]
  def change
    create_table :stores do |t|
      t.string :name
      t.string :store_type
      t.references :merchant, foreign_key: true

      t.timestamps
    end
  end
end
