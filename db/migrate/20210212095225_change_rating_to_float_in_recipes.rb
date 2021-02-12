class ChangeRatingToFloatInRecipes < ActiveRecord::Migration[5.2]
  def change
      remove_column :recipes, :rating
      add_column :recipes, :rating, :float
  end
end
