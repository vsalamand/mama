require 'open-uri'

class Item < ApplicationRecord
  # validates :ingredient_id, presence: true
  # validates :ingredient_id, uniqueness: { scope: [:recipe_id, :unit_id] }

  belongs_to :food, optional: true
  belongs_to :recipe, optional: true
  belongs_to :list_item, optional: true
  belongs_to :unit, optional: true
  # validates :food_id, presence: true
  has_many :cart_items, dependent: :destroy
  has_many :store_cart_items, dependent: :destroy

  scope :to_validate, -> { where(is_validated: false) }


  def self.add_list_items(list_items_array)
    new_items = []
    # get parsing for each list item that does not have an item yet
    queries = list_items_array.map{|list_item| "query=#{list_item.name}" if list_item.items.empty? }

    unless queries.compact.empty?
      url = URI.parse(URI::encode("https://smartmama.herokuapp.com/api/v1/parse/items?#{queries.join("&")}")
      # url = URI.parse(URI::encode("http://127.0.0.1:5000/api/v1/parse/items?#{queries.join("&")}"))
      parser = JSON.parse(open(url).read)

      parser.each_with_index do |element, index|
        quantity = element['quantity_match'] if element['quantity_match'].present?
        food = Food.search(element['food_match'], fields: [{name: :exact}], misspellings: {edit_distance: 1}).first if element['food_match'].present?
        unit = Unit.search(element['unit_match'], fields: [{name: :exact}], misspellings: {edit_distance: 1}).first if element['unit_match'].present?

        new_items << Item.new(quantity: quantity, unit: unit, food: food, list_item: list_items_array[index], name: list_items_array[index].name, is_validated: false)
      end

      Item.import new_items
    end
  end


  def self.add_recipe_items(recipe)
    new_items = []
    url = URI.parse("https://smartmama.herokuapp.com/api/v1/parse/recipe?id=#{recipe.id}")
    # url = URI.parse("http://127.0.0.1:5000/api/v1/parse/recipe?id=#{recipe.id}")

    parser = JSON.parse(open(url).read)

    parser.each do |element|
      quantity = element['quantity_match'] if element['quantity_match'].present?
      food = Food.search(element['food_match'], fields: [{name: :exact}], misspellings: {edit_distance: 1}).first if element['food_match'].present?
      unit = Unit.search(element['unit_match'], fields: [{name: :exact}], misspellings: {edit_distance: 1}).first if element['unit_match'].present?
      new_items << Item.new(quantity: quantity, unit: unit, food: food, recipe: recipe, name: element['ingredients'])
    end

    Item.import new_items
  end

  def self.update_recipe_items(recipe)
    url = URI.parse("https://smartmama.herokuapp.com/api/v1/parse/recipe?id=#{recipe.id}")
    parser = JSON.parse(open(url).read)

    parser.each do |element|
      item = Item.find_by(recipe: recipe.id, name: element['ingredients'].strip)

      if item.nil?  #for mama recipes where recipe_ingredient has been modified but not the item recipe_ingredient
        item = Item.find_by(recipe: recipe.id, name: element['food_match'].strip)
        item.name = element['ingredients'].strip unless item.nil?
      end

      unless item.nil?
        item.quantity = element['quantity_match'] if element['quantity_match'].present?
        item.unit = Unit.search(element['unit_match'], fields: [{name: :exact}], misspellings: {edit_distance: 1}).first if element['unit_match'].present?
        #item.food = Food.search(element['food_match'], fields: [{name: :exact}], misspellings: {edit_distance: 1}).first if element['food_match'].present?
        item.save
      end
    end
  end

  def validate
    self.is_validated = true if self.food.present?
    self.save
  end

  def unvalidate
    self.is_validated = false
    self.save
  end
end
