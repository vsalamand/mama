class RenameIngredientIdToFoodId < ActiveRecord::Migration[5.0]
  def change
    rename_column :items, :ingredient_id, :food_id
  end
end
