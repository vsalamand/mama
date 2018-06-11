class ChecklistJob < ApplicationJob
  queue_as :default

  def perform
    schedule = Date.today.next_week.strftime("%W, %Y")
    # update seasonal foods and create food categories (will be removed during next refactoring)
    food_pools = Checklist.update_food_pools
    Diet.each do |diet|
      ChecklistsController.create(diet, schedule, food_pools)
    end
  end
end
