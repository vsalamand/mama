class AddListIdToRecipeListItems < ActiveRecord::Migration[5.0]
  def change
    add_reference :recipe_list_items, :list, foreign_key: true, optional: true
  end
end
