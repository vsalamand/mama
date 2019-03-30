class AddNewColumnsToRecommendations < ActiveRecord::Migration[5.0]
  def change
    add_column :recommendations, :date, :datetime
    add_column :recommendations, :description, :text
    add_column :recommendations, :image_url, :string
    add_column :recommendations, :link, :string
    add_reference :recommendations, :user, foreign_key: true
  end
end
