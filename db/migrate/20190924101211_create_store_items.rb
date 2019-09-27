class CreateStoreItems < ActiveRecord::Migration[5.0]
  def change
    create_table :store_items do |t|
      t.references :product, foreign_key: true
      t.references :store, foreign_key: true
      t.integer :store_product_id
      t.string :clean_name
      t.string :name
      t.float :price
      t.float :price_per_unit
      t.boolean :is_promo
      t.float :promo_price_per_unit
      t.string :shelter
      t.string :url
      t.string :image_url
      t.boolean :is_available

      t.timestamps
    end
  end
end
