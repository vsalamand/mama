require 'open-uri'

class Recipe < ApplicationRecord
  validates :title, :servings, :ingredients, :instructions, :status, :origin, presence: :true
  validates :title, uniqueness: :true
  has_many :items, dependent: :destroy
  has_many :foods, through: :items
  has_many :cart_items, :as => :productable
  has_many :meta_recipe_lists, dependent: :nullify
  has_many :meta_recipes, through: :meta_recipe_lists
  has_many :recipe_list_items, dependent: :destroy, inverse_of: :recipe
  has_many :recipe_lists, through: :recipe_list_items

  accepts_nested_attributes_for :recipe_list_items

  RATING = ["excellent", "good", "limit", "avoid"]

  acts_as_ordered_taggable
  acts_as_taggable_on :categories

  searchkick language: "french"

  # before_save do
  #   # update to cloudinary
  #   self.upload_to_cloudinary
  # end

  def search_data
    {
      title: title,
      ingredients: ingredients,
      tags: tag_list,
      categories: category_list,
      status: status
    }
  end

  def self.search_by_food(type, foods)
    return Recipe.where(status: "published").tagged_with(type).select { |r| (foods & r.foods).any? }.sort_by { |r| (foods & r.foods).count }.reverse
  end

  def upload_to_cloudinary
    if self.status == "published" &&  Rails.env.production?
      file = open("https://www.foodmama.fr/recipes/#{self.id}.pdf")
      Cloudinary::Uploader.upload(file, :public_id => self.id, :invalidate => true)
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

  def get_best_store
    store_prices = []
    Store.all.each do |store|
      store_prices << [store.get_cheapest_cart_price(self.items)[0], store]
    end
    return store_prices.min
  end

  def add_to_pool
    tags = self.tag_list

    case
      when tags.first == "légumes" || tags.first == "légumes secs" || tags.first == "céréales"
        then self.category_list = "veggie"

      when tags.first == "crudités"
        then self.category_list = "salad"

      when tags.first == "pâtes"
        then self.category_list = "pasta"

      when tags.first == "patates"
        then self.category_list = "potato"

      when tags.first == "viandes" || tags.first == "charcuteries"
        then self.category_list = "meat"

      when tags.first == "poissons"
        then self.category_list = "fish"

      when tags.first == "oeufs"
        then self.category_list = "egg"

      when tags.first == "pizzas"
        then self.category_list = "pizza"

      when tags.first == "hamburgers"
        then self.category_list = "burger"

      when tags.first == "pains"
        then self.category_list = "snack"
    end

    self.save
  end

  def seasonal?
    seasonal_foods = FoodList.find_by(name: "seasonal foods", food_list_type: "pool")

    if (self.foods - seasonal_foods.foods).empty?
      self.category_list.add("seasonal")
    else
      self.category_list.remove("seasonal")
    end

    self.save
  end

  def get_emoji
    return "🥕" if self.category_list.include?("veggie")
    return "🥗" if self.category_list.include?("salad")
    return "🥔" if self.category_list.include?("potato")
    return "🍖" if self.category_list.include?("meat")
    return "🐟" if self.category_list.include?("fish")
    return "🍝" if self.category_list.include?("pasta")
    return "🍕" if self.category_list.include?("pizza")
    return "🍔" if self.category_list.include?("burger")
    return "🍳" if self.category_list.include?("egg")
    return "🥪" if self.category_list.include?("snack")
  end

  # def get_shelves
  #   shelves = Hash.new
  #   self.foods.tag_counts_on(:shelves).each do |shelf|
  #     shelves["#{shelf.name}"] = self.foods.tagged_with("#{shelf.name}")
  #   end

  #   return shelves
  # end

end
