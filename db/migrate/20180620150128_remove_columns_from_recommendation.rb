class RemoveColumnsFromRecommendation < ActiveRecord::Migration[5.0]
  def change
    remove_column :recommendations, :recommendation_date, :date
    remove_column :recommendations, :daily_reco, :string
  end
end
