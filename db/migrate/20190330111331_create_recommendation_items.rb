class CreateRecommendationItems < ActiveRecord::Migration[5.0]
  def change
    create_table :recommendation_items do |t|
      t.string :name
      t.references :recommendation, foreign_key: true
      t.references :recipe_list, foreign_key: true

      t.timestamps
    end
  end
end
