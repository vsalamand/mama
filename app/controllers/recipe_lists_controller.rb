class RecipeListsController < ApplicationController
  before_action :authenticate_admin!

  def index
    @recipe_lists = RecipeList.where(recipe_list_type: "curated")
  end

  def show
    @recipe_list = RecipeList.find(params[:id])
    @recipe_list.recipe_list_items.build
    @checklist = Checklist.get_checklist(@recipe_list.foods)
  end

  def new
    @recipe_list = RecipeList.new
  end

  def create
    @recipe_list = RecipeList.new(recipe_list_params)
    @recipe_list.recipe_list_type = "curated"
    if @recipe_list.save
      @recipe_list.get_description
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
    @recipe_list.get_description
    redirect_to recipe_list_path(@recipe_list)
  end

  private
  def recipe_list_params
    params.require(:recipe_list).permit(:id, :name, :user_id, :diet_id, :description, :status, :tag_list, :recipe_list_type, recipe_ids: [])
  end
end
