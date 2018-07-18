class ChecklistJob < ApplicationJob
  queue_as :default

  def perform
    schedule = Date.today.next_week.strftime("%W, %Y")
    # update seasonal foods and create food categories (will be removed during next refactoring)
    FoodList.update_food_pools
    Diet.all.each do |diet|
      ChecklistsController.create(diet, schedule)
    end
  end
end
