class MamaJob < ApplicationJob
  queue_as :default

  def perform
    # Update food lists
    FoodListJob.perform_now
    # Update recipe lists
    RecipeListJob.perform_now
    # create recipe recommendations for the week
    Diet.all.each do |diet|
      RecommendationsController.create(diet)
    end
    # update users weekly recommendations menu
    WeeklyMenuJob.perform_now
    # create food checklists for the week after
    ChecklistJob.perform_now
  end
end
