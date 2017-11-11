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
      generate_recipe_items(@recipe)
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

  def generate_recipe_items(recipe)
  recipe = Recipe.find(recipe)
  recipe_ingredients = recipe.ingredients.split("\r\n")
  recipe_ingredients.each do |element|
      ingredient = Ingredient.search(element.tr("0-9", "").tr("'", " "), operator: "or")
      element_less_ingredient = element.tr("0-9", "").downcase.split - ingredient[0]["name"].downcase.split
      unit = Unit.search(element_less_ingredient.join(' '), operator: "or")
      quantity = element[/[+-]?([0-9]*[\D])?[0-9]+/]
      Item.create(ingredient: ingredient[0], unit: unit[0], quantity: quantity, recipe: recipe, recipe_ingredient: element)
    end
  end
end
