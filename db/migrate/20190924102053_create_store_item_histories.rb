class CreateStoreItemHistories < ActiveRecord::Migration[5.0]
  def change
    create_table :store_item_histories do |t|
      t.references :store_item, foreign_key: true
      t.float :price_per_unit
      t.boolean :is_promo
      t.boolean :is_available
      t.date :date

      t.timestamps
    end
  end
end
