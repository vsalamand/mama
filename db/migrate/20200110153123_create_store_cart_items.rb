class CreateStoreCartItems < ActiveRecord::Migration[5.0]
  def change
    create_table :store_cart_items do |t|
      t.references :store_cart, foreign_key: true
      t.references :store_item, foreign_key: true

      t.timestamps
    end
  end
end
