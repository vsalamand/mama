class ChangeType < ActiveRecord::Migration[5.0]
  def change
    rename_column :recipe_lists, :type, :recipe_list_type
  end
end
