class AddCompletedToListItems < ActiveRecord::Migration[5.0]
  def change
    add_column :list_items, :is_completed, :boolean, default: false
  end
end
