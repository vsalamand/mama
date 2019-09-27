class AddSheltersToStoreItems < ActiveRecord::Migration[5.0]
  def change
    add_column :store_items, :shelters, :text, array: true, default: []
  end
end
