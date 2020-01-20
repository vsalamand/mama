class AddStatusToLists < ActiveRecord::Migration[5.0]
  def change
    add_column :lists, :status, :string, :default => "archived"
  end
end
