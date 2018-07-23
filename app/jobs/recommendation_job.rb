class RecommendationJob < ApplicationJob
  queue_as :default

  def perform
    # create recipe recommendations for the week
    Diet.all.each do |diet|
      RecommendationsController.create(diet)
    end
  end
end
