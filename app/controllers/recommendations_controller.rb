require 'date'

class RecommendationsController < ApplicationController

  def self.create(diet, schedule)
    types = ["rapide", "léger", "snack", "tarte salée", "gourmand"]
    types.each do |type|
      # vérifier si l'objet recommendation existe déjà (au cas où l'on relance le process)
      recommendation = Recommendation.find_by(diet_id: diet.id, schedule: schedule, recommendation_type: type)
      # s'il n'existe pas, alors créer un nouvel objet
      if recommendation.nil?
        recommendation = Recommendation.new
        recommendation.diet_id = diet.id
        recommendation.schedule = schedule
        recommendation.recommendation_type = type
        recommendation.name = "Week #{schedule} | #{diet.name} | #{type}"
      else
        # s'il existe, alors détruire tous les items avant d'en remettre
        recommendation.recipe_list_items.destroy_all
      end
      # select recipe candidates based on diet checklist, recipes, and recommendation type
      candidates = Recommendation.get_candidates(diet, type)
      # pick recipes of the week for the bucket
      picks = Recommendation.pick_candidates(candidates, diet)
      # create recommendation object
      recommendation.save
      # add picks to the recommendation bucket
      picks.each do |recipe|
        RecipeListItem.create(recipe_id: recipe.id, position: 0, name: recipe.title, recommendation_id: recommendation.id)
      end
    end
    # update users weekly recommendations menu
    User.all.each { |user| Recommendation.update_user_weekly_menu(user, schedule) }
  end

  private
  def recommendation_params
    params.require(:recommendation).permit(:name, :schedule, :recommendation_type, :diet_id)
  end
end
