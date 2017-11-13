class RemoveRecommendableFromRecipes < ActiveRecord::Migration[5.0]
  def change
    remove_column :recipes, :recommendable, :boolean
  end
end
