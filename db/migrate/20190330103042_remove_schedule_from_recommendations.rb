class RemoveScheduleFromRecommendations < ActiveRecord::Migration[5.0]
  def change
    remove_column :recommendations, :schedule
  end
end
