class ChecklistJob < ApplicationJob
  queue_as :default

  def perform
    schedule = Date.today.next_week.strftime("%W, %Y")
    checklists = ["équilibré"]
    food_pools = Checklist.update_food_pools
    checklists.each do |type|
      ChecklistsController.create(type, schedule, food_pools)
    end
  end
end
