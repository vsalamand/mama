class AddListItemFieldsToItems < ActiveRecord::Migration[5.2]
  def change
    add_reference :items, :list, foreign_key: true, optional: true
    add_column :items, :is_deleted, :boolean, default: false
    add_column :items, :is_completed, :boolean, default: false
  end
end
