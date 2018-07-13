class RecommendationJob < ApplicationJob
  queue_as :default

  def perform
    # Update ban food list if new food in database since last update
    Diet.all.each { |diet| FoodList.update_banned_foods(diet) } if Food.where("updated_at > ?", DateTime.now - 7).any?
    # Update recipe lists
    RecipeList.update_recipe_pools
    schedule = Date.today.strftime("%W, %Y")
    # create recipe recommendations for the week
    Diet.all.each do |diet|
      RecommendationsController.create(diet, schedule)
    end
    # create food checklists for the week after
    ChecklistJob.perform_now
  end
end
