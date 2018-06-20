require 'date'

class RecommendationsController < ApplicationController

  def self.create(diet, schedule)
    types = ["rapide", "léger", "snack", "tarte salée", "gourmand"]
    types.each do |type|
      recommendation = Recommendation.new
      recommendation.diet_id = diet.id
      recommendation.schedule = schedule
      recommendation.recommendation_type = type
      recommendation.name = "Week #{schedule} | #{diet.name} | #{type}"
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
    Recommendation.update_user_weekly_menu(User.all, schedule)
  end

  private
  def recommendation_params
    params.require(:recommendation).permit(:name, :schedule, :recommendation_type, :diet_id)
  end
end
