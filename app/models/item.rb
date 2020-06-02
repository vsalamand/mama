require 'open-uri'

class Item < ApplicationRecord
  # validates :ingredient_id, presence: true
  # validates :ingredient_id, uniqueness: { scope: [:recipe_id, :unit_id] }

  belongs_to :food, optional: true
  belongs_to :recipe, optional: true
  belongs_to :list_item, optional: true
  belongs_to :unit, optional: true
  belongs_to :store_section, optional: true

  # validates :food_id, presence: true
  has_many :cart_items, dependent: :destroy
  has_many :store_cart_items, dependent: :destroy

  scope :to_validate, -> { where(is_validated: false) }
  scope :list_items_to_validate, -> { where(is_validated: false).where.not(:list_item_id => nil ) }
  scope :recipe_items_to_validate, -> { includes(:recipe).where(is_validated: false).where.not(:recipe_id => nil ).where(:recipes => { :status => "published" } ) }

  # update item validations if new item is validated
  after_save do
    self.validate if self.is_validated == true
  end


  def self.add_list_items(list_items_array)
    new_items = []

    # get parsing for each list item that does not have an item yet
    cleaned_list_items = list_items_array.select{|list_item| list_item.item.nil? }

    queries = cleaned_list_items.map{|list_item| "query=#{list_item.name}" }.compact

    unless queries.compact.empty?
      url = URI.parse(URI::encode("https://smartmama.herokuapp.com/api/v1/parse/items?#{queries.join("&")}"))
      # url = URI.parse(URI::encode("http://127.0.0.1:5000/api/v1/parse/items?#{queries.join("&")}"))
      parser = JSON.parse(open(url).read)

      parser.each_with_index do |element, index|
        quantity = element['quantity_match'] if element['quantity_match'].present?
        food = Food.search(element['food_match'], fields: [{name: :exact}], misspellings: {edit_distance: 1}).first if element['food_match'].present?
        unit = Unit.search(element['unit_match'], fields: [{name: :exact}], misspellings: {edit_distance: 1}).first if element['unit_match'].present?
        # Attention !! index must be set on clean array otherwise item creation is all mixed up :(
        new_items << Item.new(quantity: quantity, unit: unit, food: food, list_item: cleaned_list_items[index], name: cleaned_list_items[index].name, is_validated: false)
      end

      Item.import new_items
    end
  end

  def set(list_item)
    query = "query=#{list_item.name}"
    url = URI.parse(URI::encode("https://smartmama.herokuapp.com/api/v1/parse/items?#{query}"))
    # url = URI.parse(URI::encode("http://127.0.0.1:5000/api/v1/parse/items?#{query}"))
    parser = JSON.parse(open(url).read).first

    quantity = parser['quantity_match'] if parser['quantity_match'].present?
    food = Food.search(parser['food_match'], fields: [{name: :exact}], misspellings: {edit_distance: 1}).first if parser['food_match'].present?
    unit = Unit.search(parser['unit_match'], fields: [{name: :exact}], misspellings: {edit_distance: 1}).first if parser['unit_match'].present?
    # Attention !! index must be set on clean array otherwise item creation is all mixed up :(
    self.update(quantity: quantity, unit: unit, food: food, list_item: list_item, name: list_item.name, is_validated: false)
  end

  def self.add_recipe_items(recipe)
    new_items = []
    url = URI.parse("https://smartmama.herokuapp.com/api/v1/parse/recipe?id=#{recipe.id}")
    # url = URI.parse("http://127.0.0.1:5000/api/v1/parse/recipe?id=#{recipe.id}")

    parser = JSON.parse(open(url).read)

    parser.each do |element|
      valid_item = Item.where("lower(name) = ?", element['ingredients'].downcase).where(is_validated: true).first

      if valid_item.present?
        new_items << Item.new(quantity: valid_item.quantity, unit: valid_item.unit, food: valid_item.food, recipe: recipe, name: element['ingredients'], is_validated: valid_item.is_validated)

      else
        quantity = element['quantity_match'] if element['quantity_match'].present?
        food = Food.search(element['food_match'], fields: [{name: :exact}], misspellings: {edit_distance: 1}).first if element['food_match'].present?
        unit = Unit.search(element['unit_match'], fields: [{name: :exact}], misspellings: {edit_distance: 1}).first if element['unit_match'].present?
        new_items << Item.new(quantity: quantity, unit: unit, food: food, recipe: recipe, name: element['ingredients'], is_validated: false)
      end
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
    self.update_column(:is_validated, true) if self.food.present?

    if self.is_validated == true
      # Thread.new do
        # validate any items with same name and not yet validated
        Item.where("lower(name) = ?", self.name.downcase)
            .update_all(quantity: self.quantity,
                     unit_id: self.unit_id,
                     food_id: self.food_id,
                     is_validated: self.is_validated)
      # end
    end

    # method to create items for list items that have no associated item
    missing_list_items_items = ListItem.left_outer_joins(:item).where(items: {id: nil})
    matching_list_items = missing_list_items_items.select{ |el| el.name.downcase == self.name.downcase}
    if matching_list_items.any?
      new_validated_items = []
      matching_list_items.each do |list_item|
        new_validated_items << Item.new(food: self.food, list_item: list_item, name: list_item.name, is_validated: self.is_validated, quantity: self.quantity, unit: self.unit)
      end
      Item.import new_validated_items
    end
  end

  def unvalidate
    self.update_column(:is_validated, false)
  end

  def get_store_section
    if self.store_section_id.present?
      return self.store_section
    elsif self.food.present?
      return self.food.store_section
    else
      return nil
    end
  end
end
