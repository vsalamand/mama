class DietsController < ApplicationController
  def create
    @diet = Diet.new(diets_params)
    FoodList.find_or_create_by(name: "Diet banned food list | #{@diet.name}", diet_id: diet.id, food_list_type: "ban")
    RecipeList.find_or_create_by(name: "Diet seasonal recipes | #{@diet.name}", diet_id: diet.id, recipe_list_type: "pool")
    @diet.save
  end

  private
  def diets_params
    params.require(:diet).permit(:diet_id, :name, :description, :is_active)
  end
end
