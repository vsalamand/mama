class AddNameToRecipeListItems < ActiveRecord::Migration[5.0]
  def change
    add_column :recipe_list_items, :name, :string
  end
end
