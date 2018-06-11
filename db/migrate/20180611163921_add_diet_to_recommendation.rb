class AddDietToRecommendation < ActiveRecord::Migration[5.0]
  def change
    add_reference :recommendations, :diet, foreign_key: true
  end
end
