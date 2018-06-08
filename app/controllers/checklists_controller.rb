class ChecklistsController < ApplicationController

  def self.create(diet, schedule, food_pools)
    checklist = Checklist.new
    checklist.schedule = schedule
    checklist.name = "Week #{schedule} | #{diet.name}"
    checklist.save
    Checklist.create_diet_checklist(checklist, diet, food_pools)
  end

  private
  def checklist_params
    params.require(:checklist).permit(:name, :schedule, :diet)
  end
end
