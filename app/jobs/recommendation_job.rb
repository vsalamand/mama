class RecommendationJob < ApplicationJob
  queue_as :default

  def perform
    Recommendation.update_food_pools
    Recommendation.update_weekly_food_checklist
    Recommendation.update_recipe_pool
    schedule = Date.today.strftime("%W, %Y")
    recommendations = ["classique", "express", "gourmand"]
    recommendations.each do |type|
      RecommendationsController.create(type, schedule)
    end
  end
end
