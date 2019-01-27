class Food < ApplicationRecord
  validates :name, uniqueness: true, presence: :true
  has_many :items
  has_many :recipes, through: :items
  has_many :meta_recipe_items
  has_many :meta_recipes, through: :meta_recipe_items
  has_many :cart_items, :as => :productable
  belongs_to :category
  has_many :banned_foods
  has_many :diets, through: :banned_foods
  has_many :food_list_items
  has_many :food_lists, through: :food_list_items


  acts_as_ordered_taggable
  acts_as_taggable_on :shelves

  has_ancestry
  searchkick

  after_create do
    self.add_to_shelf
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

  def self.select_seasonal_food(foods)
    return foods.select { |food| food.availability.include?(Date.today.next_week.strftime("%m") )}
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
