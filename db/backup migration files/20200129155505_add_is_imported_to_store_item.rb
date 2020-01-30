class AddIsImportedToStoreItem < ActiveRecord::Migration[5.0]
  def change
    add_column :store_items, :is_imported, :boolean, default: false
  end
end
