class CreateCartItems < ActiveRecord::Migration[5.0]
  def change
    create_table :cart_items do |t|
      t.string :name
      t.references :productable, polymorphic: true, index: true
      t.integer :quantity
      t.references :cart, foreign_key: true

      t.timestamps
    end
  end
end
