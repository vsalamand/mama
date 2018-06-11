class ChecklistsController < ApplicationController

  def self.create(diet, schedule, food_pools)
    checklist = Checklist.new
    checklist.schedule = schedule
    checklist.diet_id = diet.id
    checklist.name = "Week #{schedule} | #{diet.name}"
    checklist.save
    Checklist.pick_foods(diet, food_pools)
  end

  private
  def checklist_params
    params.require(:checklist).permit(:name, :schedule, :diet_id)
  end
end
