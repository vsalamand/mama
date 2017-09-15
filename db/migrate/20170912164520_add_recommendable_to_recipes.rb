class AddRecommendableToRecipes < ActiveRecord::Migration[5.0]
  def change
    add_column :recipes, :recommendable, :boolean
  end
end
