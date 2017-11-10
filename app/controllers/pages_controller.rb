class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home, :search, :confirmation]

  def home
  end

  def confirmation
  end

  def generate_recipe_items
    recipe = Recipe.find(4)
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
