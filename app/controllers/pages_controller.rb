class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home, :search]

  def home
  end

  def search
    search = params[:query].present? ? params[:query] : nil
    @recipes = if search
      Recipe.search(search)
    end
  end

  def suggest
    @suggestions = []
    @suggestions << starter = Recipe.search("entrée snack", operator: "or", fields: [:tags], where: {recommendable: true}).to_a.shuffle.take(1)
    @suggestions << light_dish = Recipe.search("accompagnement", fields: [:tags], where: {recommendable: true}).to_a.shuffle.take(1)
    @suggestions << main_dish = Recipe.search("plat", fields: [:tags], where: {recommendable: true}).to_a.shuffle.take(1)
    @suggestions << dessert = Recipe.search("dessert", fields: [:tags], where: {recommendable: true}).to_a.shuffle.take(1)
  end

  def generate_recipe_items
    recipe = Recipe.find(2)
    recipe_ingredients = recipe.ingredients.split("\r\n")
    recipe_ingredients.each do |element|
      ingredient = Ingredient.search(element.tr("0-9", ""), operator: "or")
      unit = Unit.search(element.tr("0-9", ""), operator: "or")
      quantity = element[/[+-]?([0-9]*[\D])?[0-9]+/]
      Item.create(ingredient: ingredient[0], unit: unit[0], quantity: quantity, recipe: recipe, recipe_ingredient: element)
    end
  end
end
