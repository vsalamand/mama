class RecommendationJob < ApplicationJob
  queue_as :default

  def perform
    checklist = Recommendation.update_weekly_food_checklist
    recipe_pool = Recommendation.update_recipe_pool
    schedule = Date.today.strftime("%W, %Y")
    recommendations = ["classique", "express", "gourmand"]
    recommendations.each do |type|
      RecommendationsController.create(type, schedule, recipe_pool, checklist)
    end
  end
end
