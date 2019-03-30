class RemoveRecommendationIdFromRecipeListItems < ActiveRecord::Migration[5.0]
  def change
    remove_reference :recipe_list_items, :recommendation, index: true, foreign_key: true
  end
end
