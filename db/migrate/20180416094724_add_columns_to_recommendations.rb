class AddColumnsToRecommendations < ActiveRecord::Migration[5.0]
  def change
    add_column :recommendations, :recommendation_type, :string
    add_column :recommendations, :schedule, :string
    add_column :recommendations, :content, :string
  end
end
