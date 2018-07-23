class ChecklistJob < ApplicationJob
  queue_as :default

  def perform
    schedule = Date.today.next_week.strftime("%W, %Y")
    Diet.all.each do |diet|
      ChecklistsController.create(diet, schedule)
    end
  end
end
