class RecipeListsController < ApplicationController

  def index
    @recipe_lists = RecipeList.where(recipe_list_type: "curated")
  end

  def show
    @recipe_list = RecipeList.find(params[:id])
  end

  def new
    @recipe_list = RecipeList.new
  end

  def create
    @recipe_list = RecipeList.new(recipe_list_params)
    @recipe_list.recipe_list_type = "curated"
    if @recipe_list.save
      redirect_to recipe_list_path(@recipe_list)
    else
      redirect_to new_recipe_list_path
    end
  end

  def edit
    @recipe_list = RecipeList.find(params[:id])
  end

  private
  def recipe_list_params
    params.require(:recipe_list).permit(:name, :user_id, :diet_id, :description, :recipe_list_type)
  end
end
