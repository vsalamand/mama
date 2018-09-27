class MetaRecipesController < ApplicationController
  before_action :set_meta_recipe, only: [ :show, :edit, :update ]

def new
  @meta_recipe = MetaRecipe.new
end

def create
  @meta_recipe = MetaRecipe.new(meta_recipe_params)
  if @meta_recipe.save
    redirect_to meta_recipe_path(@meta_recipe)
  else
    redirect_to new_meta_recipe_path
  end
end

private
  def set_meta_recipe
    @meta_recipe = MetaRecipe.find(params[:id])
  end

  def meta_recipe_params
    params.require(:meta_recipe).permit(:name, :servings, :ingredients, :instructions)
  end
end