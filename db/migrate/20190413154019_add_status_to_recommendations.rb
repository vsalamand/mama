class AddStatusToRecommendations < ActiveRecord::Migration[5.0]
  def change
    add_column :recommendations, :is_active, :boolean, default: false
  end
end
