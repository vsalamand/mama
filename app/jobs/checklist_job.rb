class ChecklistJob < ApplicationJob
  queue_as :default

  def perform
    schedule = Date.today.next_week.strftime("%W, %Y")
    food_pools = Checklist.update_food_pools
    Diet.where(is_active: true).each do |diet|
      ChecklistsController.create(diet, schedule, food_pools)
    end
  end
end
