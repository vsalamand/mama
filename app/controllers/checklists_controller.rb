class ChecklistsController < ApplicationController

  def self.create(diet, schedule)
    # vérifier si l'objet Checklist existe déjà (au cas où l'on relance le process)
    checklist = Checklist.find_by(diet_id: diet.id, schedule: schedule)
    # s'il n'existe pas, alors créer un nouvel objet
    if checklist.nil?
      checklist = Checklist.new
      checklist.schedule = schedule
      checklist.diet_id = diet.id
      checklist.name = "Week #{schedule} | #{diet.name}"
      checklist.save
    else
      # s'il existe, alors détruire tous les items avant d'en remettre
      checklist.food_list_items.destroy_all
    end
    Checklist.pick_foods(diet)
  end

  private
  def checklist_params
    params.require(:checklist).permit(:name, :schedule, :diet_id)
  end
end
