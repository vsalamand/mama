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
  has_ancestry
  searchkick

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
end
