class FoodListJob < ApplicationJob
  queue_as :default

  def perform
    Food.reindex
    # Update ban diet food list if new food in database since last update
    Diet.all.each { |diet| FoodList.update_banned_foods(diet) } if Food.where("updated_at > ?", DateTime.now - 7).any?
    # update seasonal foods and create food categories
    FoodList.update_food_pools
  end
end
