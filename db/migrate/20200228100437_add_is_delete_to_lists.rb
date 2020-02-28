class AddIsDeleteToLists < ActiveRecord::Migration[5.0]
  def change
    add_column :lists, :is_deleted, :boolean, default: false
  end
end
