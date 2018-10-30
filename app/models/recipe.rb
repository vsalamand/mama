require 'open-uri'

class Recipe < ApplicationRecord
  validates :title, :servings, :ingredients, :instructions, :status, :origin, presence: :true
  validates :title, uniqueness: :true
  has_many :items, dependent: :destroy
  has_many :foods, through: :items
  has_many :cart_items, :as => :productable
  has_many :meta_recipe_lists, dependent: :nullify
  has_many :meta_recipes, through: :meta_recipe_lists
  has_many :recipe_list_items
  has_many :recipe_lists, through: :recipe_list_items

  RATING = ["excellent", "good", "limit", "avoid"]

  acts_as_ordered_taggable

  searchkick

  before_save do
    # update to cloudinary
    self.upload_to_cloudinary
  end

  def search_data
    {
      title: title,
      ingredients: ingredients,
      tags: tag_list,
      status: status
    }
  end

  def upload_to_cloudinary
    if self.status == "published" &&  Rails.env.production?
      file = open("https://www.foodmama.fr/recipes/#{self.id}.pdf")
      Cloudinary::Uploader.upload(file, :public_id => self.id)
    end
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
      Item.find_or_create_by(food: food.first, recipe: self, recipe_ingredient: element)
    end
  end

  def add_to_pool
    tags = self.tag_list
    case
      when tags.first == "légumes" || tags.first == "légumes secs" && tags.exclude?("viandes") && tags.exclude?("charcuteries")
        then
          pool = RecipeList.find_or_create_by(name: "veggies", recipe_list_type: "pool")
          RecipeListItem.find_or_create_by(name: self.title, recipe_id: self.id, recipe_list_id: pool.id)

      when tags.first == "crudités" && tags.include?("vinaigrettes")
        then
          pool = RecipeList.find_or_create_by(name: "salads", recipe_list_type: "pool")
          RecipeListItem.find_or_create_by(name: self.title, recipe_id: self.id, recipe_list_id: pool.id)

      when tags.first == "pâtes"
        then
          pool = RecipeList.find_or_create_by(name: "pasta", recipe_list_type: "pool")
          RecipeListItem.find_or_create_by(name: self.title, recipe_id: self.id, recipe_list_id: pool.id)

      when tags.first == "viandes" || tags.first == "charcuteries"
        then
          pool = RecipeList.find_or_create_by(name: "meat", recipe_list_type: "pool")
          RecipeListItem.find_or_create_by(name: self.title, recipe_id: self.id, recipe_list_id: pool.id)

      when tags.include?("poissons")
        then
          pool = RecipeList.find_or_create_by(name: "fish", recipe_list_type: "pool")
          RecipeListItem.find_or_create_by(name: self.title, recipe_id: self.id, recipe_list_id: pool.id)

      when tags.first == "patates"
        then
          pool = RecipeList.find_or_create_by(name: "potatoes", recipe_list_type: "pool")
          RecipeListItem.find_or_create_by(name: self.title, recipe_id: self.id, recipe_list_id: pool.id)

      when tags.first == "oeufs"
        then
          pool = RecipeList.find_or_create_by(name: "eggs", recipe_list_type: "pool")
          RecipeListItem.find_or_create_by(name: self.title, recipe_id: self.id, recipe_list_id: pool.id)

      when tags.first == "pains hamburger"
        then
          pool = RecipeList.find_or_create_by(name: "hamburgers", recipe_list_type: "pool")
          RecipeListItem.find_or_create_by(name: self.title, recipe_id: self.id, recipe_list_id: pool.id)

      when tags.first == "pains"
        then
          pool = RecipeList.find_or_create_by(name: "snacks", recipe_list_type: "pool")
          RecipeListItem.find_or_create_by(name: self.title, recipe_id: self.id, recipe_list_id: pool.id)

      when tags.first == "pâtes à tarte"
        then
          pool = RecipeList.find_or_create_by(name: "pizzas & pies", recipe_list_type: "pool")
          RecipeListItem.find_or_create_by(name: self.title, recipe_id: self.id, recipe_list_id: pool.id)

      when tags.first == "céréales"
        then
          pool = RecipeList.find_or_create_by(name: "cereals", recipe_list_type: "pool")
          RecipeListItem.find_or_create_by(name: self.title, recipe_id: self.id, recipe_list_id: pool.id)
    end
  end

end
