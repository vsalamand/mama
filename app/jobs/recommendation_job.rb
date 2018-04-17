class RecommendationJob < ApplicationJob
  queue_as :default

  def perform
    schedule = Date.today.strftime("%W, %Y")
    recommendations = ["rapide", "snack", "léger", "tarte salée", "gourmand"]
    recommendations.each do |type|
      RecommendationsController.create(type, schedule)
    end
  end
end
