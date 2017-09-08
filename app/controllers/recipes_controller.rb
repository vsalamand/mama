class RecipesController < ApplicationController
  before_action :set_recipe, only: :show
  skip_before_action :authenticate_user!, only: [ :show ]

  private
  def set_recipe
    @recipe = Recipe.find(params[:id])
  end

  def recipe_params
    params.require(:recipe).permit(:title, :servings, :ingredients, :instructions, :tag_list)
  end
end
