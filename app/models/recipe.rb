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
  scope :search_import, -> { where(status: "published") }

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
    if self.status == "published" &&  Rails.env.production?
      file = open("https://www.foodmama.fr/recipes/#{self.id}.pdf")
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
      csv[0..5].each do |row|
        data = row.to_h

        Recipe.find_by(link: data["url"]).nil? ? recipe = Recipe.new : recipe = Recipe.find_by(link: data["url"])

        recipe.title = data["name"]
        recipe.link = data["url"]
        recipe.ingredients = data["recipeIngredient"].join("\r\n")
        recipe.instructions = data["recipeInstructions"].join("\r\n")
        recipe.servings = data["recipeYield"]
        recipe.image_url = data["image"].first
        recipe.origin =  data["author"]
        recipe.status = "published"

        if recipe.save
          Item.add_recipe_items(recipe)
          puts "#{recipe.name}"
        else
          unvalid_recipes << recipe.title
        end
      end

      if unvalid_recipes.any?
        puts "#{unvalid_recipes.size}"
        puts "#{unvalid_recipes.map(&:name).join(", ")}"
      end

    end
  end

  # Import CSV
  def self.import(file)
    csv = CSV.read(file.path, headers: true)
    ImportCatalogJob.perform_now(catalog)
  end


end
