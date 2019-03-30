class ChangeRecommendationNameToTitle < ActiveRecord::Migration[5.0]
  def change
    rename_column :recommendations, :name, :title
  end
end
