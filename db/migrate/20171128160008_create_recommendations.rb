class CreateRecommendations < ActiveRecord::Migration[5.0]
  def change
    create_table :recommendations do |t|
      t.date :recommendation_date
      t.string :daily_reco

      t.timestamps
    end
  end
end
