require 'open-uri'

class Item < ApplicationRecord
  # validates :ingredient_id, presence: true
  # validates :ingredient_id, uniqueness: { scope: [:recipe_id, :unit_id] }

  belongs_to :food, optional: true
  belongs_to :recipe
  belongs_to :unit, optional: true

  def self.add_recipe_items(recipe)
    url = URI.parse("https://smartmama.herokuapp.com/api/v1/parse/recipe?id=#{recipe.id}")
    parser = JSON.parse(open(url).read)

    parser.each do |element|
      quantity = element['quantity_match'] if element['quantity_match'].present?
      food = Food.search(element['food_match'], fields: [{name: :exact}], misspellings: {edit_distance: 1}).first if element['food_match'].present?
      unit = Unit.search(element['unit_match'], fields: [{name: :exact}], misspellings: {edit_distance: 1}).first if element['unit_match'].present?
      Item.create(quantity: quantity, unit: unit, food: food, recipe: recipe, recipe_ingredient: element['ingredients'])
    end
  end

  def self.update_recipe_items(recipe)
    url = URI.parse("https://smartmama.herokuapp.com/api/v1/parse/recipe?id=#{recipe.id}")
    parser = JSON.parse(open(url).read)

    parser.each do |element|
      item = Item.find_by(recipe: recipe.id, recipe_ingredient: element['ingredients'].strip)

      if item.nil?  #for mama recipes where recipe_ingredient has been modified but not the item recipe_ingredient
        item = Item.find_by(recipe: recipe.id, recipe_ingredient: element['food_match'].strip)
        item.recipe_ingredient = element['ingredients'].strip unless item.nil?
      end

      unless item.nil?
        item.quantity = element['quantity_match'] if element['quantity_match'].present?
        item.unit = Unit.search(element['unit_match'], fields: [{name: :exact}], misspellings: {edit_distance: 1}).first if element['unit_match'].present?
        #item.food = Food.search(element['food_match'], fields: [{name: :exact}], misspellings: {edit_distance: 1}).first if element['food_match'].present?
        item.save
      end
    end

  end
end
