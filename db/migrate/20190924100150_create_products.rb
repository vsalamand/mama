class CreateProducts < ActiveRecord::Migration[5.0]
  def change
    create_table :products do |t|
      t.references :food, foreign_key: true
      t.integer :ean
      t.string :name
      t.float :quantity
      t.references :unit, foreign_key: true
      t.string :brand
      t.string :origin
      t.boolean :is_frozen

      t.timestamps
    end
  end
end
