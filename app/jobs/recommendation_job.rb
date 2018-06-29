class RecommendationJob < ApplicationJob
  queue_as :default

  def perform
    # create recipe recommendations of the week
    RecipeList.update_recipe_pools
    schedule = Date.today.strftime("%W, %Y")
    Diet.all.each do |diet|
      RecommendationsController.create(diet, schedule)
    end
    # create food checklists for the week after
    ChecklistJob.perform_now
  end
end
