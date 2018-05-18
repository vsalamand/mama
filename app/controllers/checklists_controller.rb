class ChecklistsController < ApplicationController

  def self.create(type, schedule, food_pools)
    checklist = Checklist.new
    checklist.checklist_type = type
    checklist.schedule = schedule
    checklist.name = "Week #{schedule} | #{type}"
    checklist.save
    case type
      when "équilibré" then Checklist.create_balanced_checklist(checklist, food_pools)
    end
  end

  private
  def checklist_params
    params.require(:checklist).permit(:name, :schedule, :checklist_type)
  end
end
