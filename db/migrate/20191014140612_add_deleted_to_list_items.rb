class AddDeletedToListItems < ActiveRecord::Migration[5.0]
  def change
    add_column :list_items, :deleted, :boolean, default: false
  end
end
