class RecipeListsController < ApplicationController

  private
  def recipe_list_params
    params.require(:recipe_list).permit(:name, :user_id, :description, :recipe_list_type)
  end
end
