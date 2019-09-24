class RemoveShelterFromStoreItems < ActiveRecord::Migration[5.0]
  def change
    remove_column :store_items, :shelter
  end
end
