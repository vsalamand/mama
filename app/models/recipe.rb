require 'open-uri'

class Recipe < ApplicationRecord
  validates :title, :servings, :ingredients, :instructions, :status, :origin, presence: :true
  validates :title, uniqueness: :true
  has_many :items, dependent: :destroy
  has_many :foods, through: :items
  has_many :cart_items, :as => :productable
  has_many :meta_recipe_lists, dependent: :nullify
  has_many :meta_recipes, through: :meta_recipe_lists

  RATING = ["excellent", "good", "limit", "avoid"]

  acts_as_ordered_taggable

  searchkick

  def search_data
    {
      title: title,
      ingredients: ingredients,
      tags: tag_list,
      status: status
    }
  end

  def upload_to_cloudinary
    file = open("https://www.foodmama.fr/recipes/#{self.id}.pdf")
    Cloudinary::Uploader.upload(file, :public_id => self.id)
  end


  def rate
    # get ratings for each food in recipe
    food_ratings = []
    self.foods.each { |food| food_ratings << food.category.rating if food.category.present? && food.category.rating?}
    # set rating based on ratings from food in recipe
    case
      # rate excellent if only good foods
      when (food_ratings & ["limit", "avoid"]).empty?
        then self.rating = "excellent"
      # rate good if contains good foods and only one food to limit or avoid
      when (food_ratings & ["good"]).any? && (food_ratings - ["good"]).count <= 1
        then self.rating = "good"
      # rate limit if more than one food to limit or avoid
      when (food_ratings & ["good"]).any? && (food_ratings - ["good"]).count >= 2
        then self.rating = "limit"
      # rate avoid if does not contain any good food
      when (food_ratings & ["good"]).empty?
        then self.rating = "avoid"
    end
    self.save
  end

  def generate_items
    recipe_ingredients = self.ingredients.split("\r\n")
    recipe_ingredients.each do |element|
      element = element.strip
      food = Food.search(element.tr("0-9", "").tr("'", " "), fields: [{name: :exact}], misspellings: {edit_distance: 1})
      food = Food.search(element.tr("0-9", "").tr("'", " ")) if food.first.nil?
      food = Food.search(element.tr("0-9", "").tr("'", " "), operator: "or") if food.first.nil?
        #   element_less_ingredient = element.tr("0-9", "").downcase.split - ingredient[0]["name"].downcase.split
        #   unit = Unit.search(element_less_ingredient.join(' '), operator: "or")
        #   quantity = element[/[+-]?([0-9]*[\D])?[0-9]+/]
      Item.create(food: food.first, recipe: self, recipe_ingredient: element)
    end
  end
end
