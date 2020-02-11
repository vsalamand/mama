class Food < ApplicationRecord
  validates :name, uniqueness: true, presence: :true
  has_many :items
  has_many :recipes, through: :items
  has_many :meta_recipe_items, dependent: :destroy
  has_many :meta_recipes, through: :meta_recipe_items
  has_many :cart_items, :as => :productable
  belongs_to :category
  belongs_to :unit, optional: true
  has_many :banned_foods
  has_many :diets, through: :banned_foods
  has_many :food_list_items, dependent: :destroy
  has_many :food_lists, through: :food_list_items
  has_many :units, through: :items
  has_many :products
  has_many :store_items, through: :products
  has_many :stores, through: :store_items
  has_many :merchants, through: :stores

  enum measure: {weight: 'weight', volume: 'volume', piece: 'piece'}


  acts_as_ordered_taggable
  acts_as_taggable_on :shelves

  has_ancestry
  searchkick language: "french"

  after_create do
    self.add_to_shelf
  end

  after_commit :reindex_product

  def reindex_product
    product.reindex
  end

  def search_data
    {
      name: name,
      tags: tag_list,
    }
  end

  def parent_enum
    Food.where.not(id: id).map { |f| [ f.name, f.id ] }
  end

  def self.get_foods(query)
    foods = []
    query.split.each do |element|
         element = element.strip
         food = Food.search(element.tr("0-9", "").tr("'", " "), fields: [{name: :exact}], misspellings: {edit_distance: 1})
         food = Food.search(element.tr("0-9", "").tr("'", " ")) if food.first.nil?
         food = Food.search(element.tr("0-9", "").tr("'", " "), operator: "or") if food.first.nil?
      foods << food.first
    end
    return foods
  end

  def get_related_foods
    related_foods = []
    related_foods << self.parent if self.has_parent?
    related_foods << self.children if self.has_children?
    related_foods << self.siblings if self.has_parent? && self.has_siblings?
    return related_foods.flatten
  end

  def self.match_food(text)
    foods = []

    elements = text.split
    while elements.any? && foods.empty?
      foods << Food.find_by(name: elements.join(' '))
      foods << Food.search(elements.join(' '), misspellings: {edit_distance: 1}, body_options: {min_score: 65}).first
      foods << Food.search(elements.join(' '), body_options: {min_score: 65}).first
      elements.pop
      foods.compact!
    end

    if foods.empty?
      elements = text.split
      while elements.any?
        foods << Food.search(text, operator: "or", body_options: {min_score: 90}).first
        elements.pop
        foods.compact!
      end
    end

    foods.compact!
    return foods.first
  end

  def get_cheapest_store_item_id
    cheapest_store_item = self.store_items.pluck(:price, :id, :is_available).reject {|x| x.first < 0.02 || x[2] == false }.min
    cheapest_store_item = StoreItem.find(cheapest_store_item.second).id if cheapest_store_item.present?
    return cheapest_store_item
  end

  def get_promo_store_item
    promo_store_item = self.store_items.pluck(:is_promo, :id, :is_available).reject {|x| x[0] == false }.min
    promo_store_item = StoreItem.find(promo_store_item.second) if promo_store_item.present?
    return promo_store_item
  end

  def get_store_items
    store_items = []
    data = self.store_items.pluck(:price_per_unit, :id, :is_available).reject {|x| x.first < 0.02 || x[2] == false }
    data.each{ |store_item| store_items << StoreItem.find(store_item.second) }
    return store_items
  end

  def self.get_foods_without_product
    return Food.includes(:products).where(products: {id: nil})
  end

  def self.get_shelves(foods)
    shelves = Hash.new
    foods.tag_counts_on(:shelves).each do |shelf|
      shelves["#{shelf.name}"] = foods.tagged_with("#{shelf.name}").distinct
    end

    return shelves
  end

  def self.select_seasonal_food(foods)
    return foods.select { |food| food.availability.include?(Date.today.next_week.strftime("%m") )}
  end

  def self.get_condiment_food
    return Category.find(14).foods.tagged_with("légumes bulbes") + Category.find(6).subtree.map { |c| c.foods }.flatten + Category.find(44).foods + Category.find(38).foods + Category.find(42).foods + Category.find(39).foods + Category.find(16).foods  + Category.find(17).foods

  end

  def add_to_shelf
    if (Category.find(1).subtree - Category.find(15).subtree).include?(self.category)
      self.shelf_list = "fruits et légumes"
    elsif Category.find(3).subtree.include?(self.category)
      self.shelf_list = "légumineuses"
    elsif Category.find(15).subtree.include?(self.category)
      self.shelf_list = "oléagineux"
    elsif Category.find(2).subtree.include?(self.category)
      self.shelf_list = "céréales"
    elsif (Category.find(5).subtree + Category.find(24).subtree).include?(self.category)
      self.shelf_list = "crèmerie"
    elsif Category.find(4).subtree.include?(self.category)
      self.shelf_list = "viandes et poissons"
    else
      self.shelf_list = "épicerie"
    end

    self.save
  end

end
