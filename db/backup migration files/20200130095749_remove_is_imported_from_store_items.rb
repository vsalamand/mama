class RemoveIsImportedFromStoreItems < ActiveRecord::Migration[5.0]
  def change
    remove_column :store_items, :is_imported
  end
end
