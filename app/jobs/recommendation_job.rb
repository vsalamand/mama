class RecommendationJob < ApplicationJob
  queue_as :default

  def perform
    Recommendation.update_recipe_pool
    schedule = Date.today.strftime("%W, %Y")
    recommendations = ["rapide", "snack", "léger", "tarte salée", "gourmand"]
    recommendations.each do |type|
      RecommendationsController.create(type, schedule)
    end
  end
end
