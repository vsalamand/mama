class AddRecommendationIdToRecipeListItems < ActiveRecord::Migration[5.0]
  def change
    add_reference :recipe_list_items, :recommendation, foreign_key: true
  end
end
