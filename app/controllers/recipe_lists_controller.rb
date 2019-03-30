class RecipeListsController < ApplicationController

  def index
    @recipe_lists = RecipeList.where(recipe_list_type: "curated")
  end

  def show
    @recipe_list = RecipeList.find(params[:id])
    @recipe_list.recipe_list_items.build
  end

  def new
    @recipe_list = RecipeList.new
  end

  def create
    @recipe_list = RecipeList.new(recipe_list_params)
    @recipe_list.recipe_list_type = "curated"
    @recipe_list.get_description
    if @recipe_list.save
      redirect_to recipe_list_path(@recipe_list)
    else
      redirect_to new_recipe_list_path
    end
  end

  def edit
    @recipe_list = RecipeList.find(params[:id])
  end

  def update
    @recipe_list = RecipeList.find(params[:id])
    @recipe_list.update(recipe_list_params)
    redirect_to recipe_list_path(@recipe_list)
  end

  private
  def recipe_list_params
    params.require(:recipe_list).permit(:id, :name, :user_id, :diet_id, :description, :formula_list, :recipe_list_type, recipe_ids: [])
  end
end
