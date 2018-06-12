class AddDietToRecipeList < ActiveRecord::Migration[5.0]
  def change
    add_reference :recipe_lists, :diet, foreign_key: true
  end
end
