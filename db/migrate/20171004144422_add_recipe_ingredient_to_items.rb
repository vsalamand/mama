class AddRecipeIngredientToItems < ActiveRecord::Migration[5.0]
  def change
    add_column :items, :recipe_ingredient, :string
  end
end
