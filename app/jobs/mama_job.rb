class MamaJob < ApplicationJob
  queue_as :default

  def perform
    # Update food lists
    FoodListJob.perform_now
    # Update recipes
    Recipe.where(status: "published").each { |recipe| recipe.seasonal? }
  end
end
