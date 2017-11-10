class RecipesController < ApplicationController
  before_action :set_recipe, only: [ :show, :edit, :update ]
  skip_before_action :authenticate_user!, only: [ :show, :new, :create ]

  def pending
    @recipes = Recipe.where(status: "pending")
  end

  def new
    @recipe = Recipe.new
  end

  def create
    @recipe = Recipe.new(recipe_params)
    @recipe.status = "pending"
    @recipe.origin = "mama"
    if @recipe.save
      redirect_to confirmation_path
    else
      render 'new'
    end
  end

  def edit
  end

  private
  def set_recipe
    @recipe = Recipe.find(params[:id])
  end

  def recipe_params
    params.require(:recipe).permit(:title, :servings, :ingredients, :instructions, :tag_list, :origin, :status)
  end
end
