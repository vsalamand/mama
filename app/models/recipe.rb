require 'open-uri'

class Recipe < ApplicationRecord
  validates :title, :servings, :ingredients, :instructions, :status, :origin, presence: :true
  validates :title, uniqueness: :true
  has_many :items, dependent: :destroy
  has_many :foods, through: :items
  has_many :cart_items, :as => :productable

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

  def self.upload_to_cloudinary(recipe)
    file = open("https://www.foodmama.fr/recipes/#{recipe.id}.pdf")
    Cloudinary::Uploader.upload(file, :public_id => recipe.id)
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
end
