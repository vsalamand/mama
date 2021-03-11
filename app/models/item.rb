require 'open-uri'
require 'fuzzy_match'

class Item < ApplicationRecord
  validates :name, presence: true
  # validates :ingredient_id, uniqueness: { scope: [:recipe_id, :unit_id] }

  belongs_to :food, optional: true
  belongs_to :recipe, optional: true
  belongs_to :list_item, optional: true
  belongs_to :unit, optional: true
  belongs_to :store_section, optional: true
  belongs_to :list, optional: true
  belongs_to :category, optional: true
  has_one :food_group, through: :category

  # validates :food_id, presence: true
  has_many :cart_items, dependent: :destroy
  has_many :store_cart_items, dependent: :destroy
  has_many :item_histories, dependent: :destroy

  scope :not_deleted, -> { where(is_deleted: false) }
  scope :deleted, -> { where(is_deleted: true) }

  scope :to_validate, -> { where(is_validated: false) }
  scope :list_items_to_validate, -> { where(is_validated: false).where.not(:list_item_id => nil ) }
  scope :recipe_items_to_validate, -> { includes(:recipe).where(is_validated: false).where.not(:recipe_id => nil ).where(:recipes => { :status => "published" } ) }

  # update item validations if new item is validated
  after_update do
    if saved_change_to_name? || saved_change_to_unit_id? || saved_change_to_quantity? || saved_change_to_is_non_food?
      self.validate if self.is_validated == true
    end
    if saved_change_to_category_id?
      self.set_store_section
      self.update_score
      self.validate if self.is_validated == true
    end
  end

  before_update do
    self.set_non_food if self.is_non_food
  end

  after_create :create_item_history
  # after_create :broadcast_create
  # after_update :broadcast_update

  def broadcast_create
    # render through broadcast cable
    data = {
             action: "create",
             item_id: self.id,
             store_section_name: self.get_store_section_name.downcase.parameterize(separator: ''),
             message_partial_list_item: ApplicationController.renderer.render(partial: "items/show", locals: { list: self.list, item: self }),
             message_partial_form: ApplicationController.renderer.render(partial: "items/list_item_form", locals: { list: self.list, item: Item.new })
           }
    ListChannel.broadcast_to(
      "list_#{self.list.id}",
      data
    )
  end

  def broadcast_update
    if saved_change_to_is_completed? || saved_change_to_name?
      # # render through broadcast cable
      data = {
              item_id: self.id,
              message_partial: ApplicationController.renderer.render(partial: "items/show", locals: { list: self.list, item: self })
             }
      ListChannel.broadcast_to(
        "list_#{self.list.id}",
        data
      )
    elsif saved_change_to_is_deleted?
      # render through broadcast cable
      data = {
              action: "delete",
              item_id: self.id,
              store_section: self.get_store_section_name.downcase.parameterize(separator: ''),
              message_partial: ApplicationController.renderer.render(partial: "items/show", locals: { list: self.list, item: self })
            }
      ListChannel.broadcast_to(
        "list_#{self.list.id}",
        data
      )
    end
  end

  def get_valid_item
    Item.where("lower(trim(name)) = ?", self.name.downcase.strip).where(is_validated: true).first
  end

  def set
    item = self
    item.name = item.name.squeeze(' ')
    valid_item = self.get_valid_item
    if valid_item.present?
      # item.food = valid_item.food
      item.category = valid_item.category
      item.unit = valid_item.unit
      item.quantity = valid_item.quantity
      item.is_non_food = valid_item.is_non_food
      item.is_validated = valid_item.is_validated
      item.store_section_id = valid_item.store_section_id
      item.store_section_id = nil if valid_item.is_non_food
      item.is_deleted = false
      item.recipe = nil
    else
      query = "query=#{item.name}"
      url = URI.parse(URI::encode("https://smartmama.herokuapp.com/api/v1/parse/items?#{query}"))
      # url = URI.parse(URI::encode("http://127.0.0.1:5000/api/v1/parse/items?#{query}"))
      parser = JSON.parse(open(url).read).first
      quantity = parser['quantity_match'] if parser['quantity_match'].present?

      category = Category.search(parser['food_match'], misspellings: {edit_distance: 1}).first if parser['food_match'].present?
      # category = Category.search(parser['clean_item'], misspellings: {edit_distance: 1}).first if parser['food_match'].present?
      # category = Category.find_by(name: FuzzyMatch.new(Category.pluck(:name)).find(parser['food_match']))
      if category.nil? && parser['clean_item'].present?
        product = StoreItem.search(parser['clean_item'], where: {store_id: 1}).first
        category = product.get_category if product.present?
      end

      unit = Unit.search(parser['unit_match'], misspellings: {edit_distance: 1}).first if parser['unit_match'].present?

      item.quantity = quantity
      item.unit = unit
      item.category = category
      item.store_section_id = category.get_store_section.id if category.present?
      item.is_deleted = false
      item.is_validated = false
    end

    return item
  end

  def self.add_menu_to_list(ingredients, list)
    new_items = []

    queries = ingredients.map{|input| "query=#{input}" }.compact
    if ingredients.any?
      url = URI.parse(URI::encode("https://smartmama.herokuapp.com/api/v1/parse/items?#{queries.join("&")}"))
      parser = JSON.parse(open(url).read)

      parser.each_with_index do |element, index|
        quantity = element['quantity_match'] if element['quantity_match'].present?
        category = Category.search(element['food_match'], misspellings: {edit_distance: 1}).first if element['food_match'].present?
        if category.nil? && element['clean_item'].present?
          product = StoreItem.search(element['clean_item'], where: {store_id: 1}).first
          category = product.get_category if product.present?
        end
        unit = Unit.search(element['unit_match'], misspellings: {edit_distance: 1}).first if element['unit_match'].present?

        store_section_id = category.get_store_section.id if category.present?
        # Attention !! index must be set on clean array otherwise item creation is all mixed up :(
        new_item =  Item.new(name: ingredients[index].squeeze(' '),
                              category: category,
                              is_validated: false,
                              quantity: quantity,
                              unit: unit,
                              store_section_id: store_section_id,
                              is_completed: false,
                              is_deleted: false,
                              list: list)

        valid_item = Item.where("lower(trim(name)) = ?", element['clean_item'].downcase.strip).where(is_validated: true).first
        valid_item.present? ? new_item.is_validated = true : new_item.is_validated = false
        new_items << new_item
      end

      Item.import new_items
      new_items.each{ |i| i.create_item_history}
    end
  end


  def self.add_recipe_items(recipe)
    new_items = []

    ingredients = recipe.ingredients.split("\r\n")

    queries = ingredients.map{|input| "query=#{input}" }.compact
    if ingredients.any?
      url = URI.parse(URI::encode("https://smartmama.herokuapp.com/api/v1/parse/items?#{queries.join("&")}"))
      parser = JSON.parse(open(url).read)

      parser.each_with_index do |element, index|
        quantity = element['quantity_match'] if element['quantity_match'].present?
        category = Category.search(element['food_match'], misspellings: {edit_distance: 1}).first if element['food_match'].present?
        if category.nil? && element['clean_item'].present?
          product = StoreItem.search(element['clean_item'], where: {store_id: 1}).first
          category = product.get_category if product.present?
        end
        unit = Unit.search(element['unit_match'], misspellings: {edit_distance: 1}).first if element['unit_match'].present?

        store_section_id = category.get_store_section.id if category.present?
        # Attention !! index must be set on clean array otherwise item creation is all mixed up :(
        new_item =  Item.new(name: ingredients[index].squeeze(' '),
                              category: category,
                              is_validated: false,
                              quantity: quantity,
                              unit: unit,
                              store_section_id: store_section_id,
                              is_completed: false,
                              is_deleted: false,
                              recipe: recipe)

        valid_item = Item.where("lower(trim(name)) = ?", element['clean_item'].downcase.strip).where(is_validated: true).first
        valid_item.present? ? new_item.is_validated = true : new_item.is_validated = false
        new_items << new_item
      end

      Item.import new_items
      new_items.each{ |i| i.create_item_history}

    end
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
        item.unit = Unit.search(element['unit_match'], misspellings: {edit_distance: 1}).first if element['unit_match'].present?
        #item.food = Food.search(element['food_match'], fields: [{name: :exact}], misspellings: {edit_distance: 1}).first if element['food_match'].present?
        item.save
      end
    end
  end

  def validate
    self.update_column(:is_validated, true) if self.category.present?

    if self.is_validated == true
      # Thread.new do
        # validate any items with same name and not yet validated
        Item.where("lower(trim(name)) = ?", self.name.downcase.strip)
            .update_all(quantity: self.quantity,
                     unit_id: self.unit_id,
                     category_id: self.category_id,
                     store_section_id: self.store_section_id,
                     is_non_food: self.is_non_food,
                     is_validated: self.is_validated)
      # end
    end
  end

  def unvalidate
    if self.is_validated == false
      # Thread.new do
        # validate any items with same name and not yet validated
        Item.where("lower(trim(name)) = ?", self.name.downcase.strip)
            .update_all(is_validated: false)
      # end
    end
  end

  def unvalidate
    self.update_column(:is_validated, false)
  end

  # make a complete method
  def complete
    self.is_completed = true
    self.is_deleted = true
    self.save
    self.create_item_history
  end

  # make an uncomplete method
  def uncomplete
    self.is_completed = false
    self.is_deleted = false
    self.save
  end

  #create the soft delete method
  def delete
    self.is_completed = false
    self.is_deleted = true
    self.save
    self.create_item_history
  end

  def set_non_food
    if self.is_non_food
      self.update_columns(category_id: nil, unit_id: nil, store_section_id: nil)
    end
  end

  def find_saved_item(list)
    Item.where("lower(trim(name)) = ?", self.name.downcase.strip).where(list: list).where(is_completed: true).first
  end

  def get_store_section
    if self.store_section_id.present?
      return self.store_section
    elsif self.category.present?
      return self.category.store_section
    else
      return nil
    end
  end

  def set_store_section
    self.store_section_id = self.category.get_store_section.id if self.category.present?
    self.save
  end

  def get_store_section_name
    if self.store_section.present?
      self.store_section.name
    else
      return "non-alimentaires"
    end
  end

  def set_category_from_food
    if self.food.present?
      self.category = self.food.category
      self.save
    end
  end

  def get_header_name
    if self.list.sorted_by == "date"
      return "date"

    elsif self.list.sorted_by == "rayon"
      return self.get_store_section_name.downcase.parameterize(separator: '')

    elsif self.list.sorted_by == "category" && self.category.present?
      return self.category.root.name.downcase.parameterize(separator: '')

    elsif self.list.sorted_by == "foodgroup" && self.category.present? && self.category.get_food_group.present?
      return self.category.get_food_group.root.name.downcase.parameterize(separator: '')

    else
      return "non-alimentaires"
    end
  end

  def get_points
    self.category.present? ? rating = self.category.rating.to_i  : rating = 0
    case rating
      when 0 then points = 0
      when 1 then points = 3
      when 2 then points = -1
      when 3 then points = -3
    end
  end

  def update_score
    if self.list.present?
      self.list.user.scores.first.set_score
    end
  end

  def create_item_history
    ItemHistory.find_or_create_by(item_id: self.id, is_deleted: self.is_deleted)
  end
end
