class ChangeRecommendationTitleToName < ActiveRecord::Migration[5.0]
  def change
    rename_column :recommendations, :title, :name
  end
end
