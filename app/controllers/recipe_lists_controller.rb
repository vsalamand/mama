class RecipeListsController < ApplicationController

  def show
    @recipe_list = RecipeList.find(params[:id])
    @foods = FoodList.get_foodlist(@recipe_list.foods)
  end

  private
  def recipe_list_params
    params.require(:recipe_list).permit(:name, :user_id, :description, :recipe_list_type)
  end
end
