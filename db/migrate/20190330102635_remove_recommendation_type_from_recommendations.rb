class RemoveRecommendationTypeFromRecommendations < ActiveRecord::Migration[5.0]
  def change
    remove_column :recommendations, :recommendation_type
  end
end
