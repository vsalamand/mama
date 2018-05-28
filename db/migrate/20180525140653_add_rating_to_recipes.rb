class AddRatingToRecipes < ActiveRecord::Migration[5.0]
  def change
    add_column :recipes, :rating, :string
  end
end
