class RemoveDietIdFromRecipeList < ActiveRecord::Migration[5.0]
  def change
    remove_reference :recipe_lists, :diet, index: true, foreign_key: true
  end
end
