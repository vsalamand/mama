require 'open-uri'
require 'uri'
require 'csv'

class Recipe < ApplicationRecord
  validates :title, :ingredients, :status, :link, :image_url, presence: :true
  validates :link, uniqueness: :true

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
  scope :search_import, -> { where(status: "published").where.not(origin: "mama") }
  scope :to_validate, -> { includes(:items).where(status: "published").where( :items => { :is_validated => false } ) }

  # before_save do
  #   # update to cloudinary
  #   self.upload_to_cloudinary
  # end

  def search_data
    {
      title: title,
      ingredients: ingredients,
      tags: tag_list,
      categories: category_list
    }
  end

  def self.search_by_food(type, foods)
    return Recipe.where(status: "published").tagged_with(type).select { |r| (foods & r.foods).any? }.sort_by { |r| (foods & r.foods).count }.reverse
  end

  def upload_to_cloudinary
    if self.status == "published" &&  Rails.env.production? && self.image_url.present?
      file = open(URI.parse(URI.escape(self.image_url)))
      Cloudinary::Uploader.upload(file, :public_id => self.id, :invalidate => true)
    end
  end

  def add_to_recipe_list(recipe_list)
    unless recipe_list.recipes.include?(self)
      RecipeListItem.create(recipe_id: self.id,
                          recipe_list_id: recipe_list.id,
                          name: self.title)
    end
  end

  def dismiss
    self.status = "dismissed"
    self.save
  end

  def publish
    self.status = "published"
    self.save
  end


  def get_best_store
    store_prices = []
    Store.all.each do |store|
      store_prices << [store.get_cheapest_cart_price(self.items)[0], store]
    end
    return store_prices.min
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

  def self.import_csv(csv)

    unvalid_recipes = []

    Thread.new do
      csv.each do |row|

        data = row.to_h

        Recipe.find_by(link: data["url"]).nil? ? recipe = Recipe.new : recipe = Recipe.find_by(link: data["url"])

        recipe.title = data["name"].chars.select(&:valid_encoding?).join if data["name"]
        recipe.link = data["url"] if data["url"]

        # proceed with ingredients only if there is a value
        unless data["recipeIngredient"].empty?
          # rescue when single quotes in array that cant be eval
          begin
            recipe.ingredients = eval(data["recipeIngredient"]).join("\r\n").chars.select(&:valid_encoding?).join
          rescue SyntaxError
            recipe.ingredients = data["recipeIngredient"].gsub(/\'/, ' ')[1..-2].split(", ").map{|e| e.strip}.join("\r\n").chars.select(&:valid_encoding?).join
          end
          # if recipe had items, destroy so we do not generate duplicated items after save
          recipe.items.destroy_all if recipe.items.any?
        end

        unless data["recipeInstructions"].empty? || data["recipeInstructions"] == "[nan]"
          begin
            recipe.instructions = eval(data["recipeInstructions"]).join("\r\n").chars.select(&:valid_encoding?).join if data["recipeInstructions"]
          rescue SyntaxError
            recipe.instructions = data["recipeInstructions"].gsub(/\'/, ' ')[1..-2].split(", ").map{|e| e.strip}.join("\r\n").chars.select(&:valid_encoding?).join if data["recipeInstructions"]
          end
        end

        recipe.servings = data["recipeYield"] if data["recipeYield"]
        recipe.image_url = eval(data["image"]).first if data["image"]
        recipe.origin =  data["author"] if data["author"]
        recipe.status = "published"

        begin
          if recipe.save
            recipe.upload_to_cloudinary
            Item.add_recipe_items(recipe)
            puts "#{recipe.title}"
          else
            unvalid_recipes << data
          end
        rescue ActiveRecord::StatementInvalid
          unvalid_recipes << data
        end
      end

      if unvalid_recipes.any?
        puts "#{unvalid_recipes.size}"
        puts "#{unvalid_recipes}"
      end

    end
  end

  # Import CSV
  def self.import(file)
    csv = CSV.read(file.path, headers: true)
    RecipeJob.perform_now(csv)
  end


end
