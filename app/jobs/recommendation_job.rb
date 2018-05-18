class RecommendationJob < ApplicationJob
  queue_as :default

  def perform
    # create recipe recommendations of the week
    recipe_pool = Recommendation.update_recipe_pool
    schedule = Date.today.strftime("%W, %Y")
    recommendations = ["équilibré", "express", "gourmand"]
    recommendations.each do |type|
      RecommendationsController.create(type, schedule, recipe_pool)
    end
    # create food checklists for the week after
    ChecklistJob.perform_now
  end
end
