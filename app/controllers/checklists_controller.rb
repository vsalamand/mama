class ChecklistsController < ApplicationController

  def self.create(type, schedule)
    checklist = Checklist.new
    checklist.checklist_type = type
    checklist.schedule = schedule
    checklist.name = "Week #{schedule} | #{type}"
    checklist.save
    case type
      # when "classique" then Recommendation.create_classic_basket(recommendation, recipe_pool, checklist)
    end
  end

  private
  def recommendation_params
    params.require(:checklist).permit(:name, :schedule, :checklist_type)
  end
end
