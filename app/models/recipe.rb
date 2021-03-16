require 'open-uri'
require 'uri'
require 'csv'

class Recipe < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: :history

  validates :title, :ingredients, :status, :link, :image_url, presence: :true
  validates :link, uniqueness: :true

  has_many :items, dependent: :destroy
  has_many :categories, through: :items
  has_many :foods, through: :items
  has_many :cart_items, :as => :productable
  has_many :meta_recipe_lists, dependent: :nullify
  has_many :meta_recipes, through: :meta_recipe_lists
  has_many :recipe_list_items, dependent: :destroy, inverse_of: :recipe
  has_many :recipe_lists, through: :recipe_list_items

  accepts_nested_attributes_for :recipe_list_items


  RATING = ["excellent", "good", "limit", "avoid"]

  acts_as_ordered_taggable
  acts_as_taggable_on :tags
  # acts_as_taggable_on :categories

  searchkick language: "french"
  scope :search_import, -> { where(status: "published").where.not(origin: "mama") }
  scope :to_validate, -> { includes(:items).where(status: "published").where( :items => { :is_validated => false } ) }
  scope :published, -> { where(status: "published").where.not(origin: "mama") }
  scope :pending, -> { where(status: "pending").where.not(origin: "mama") }
  scope :dismissed, -> { where(status: "dismissed").where.not(origin: "mama") }
  scope :curated, -> { includes(:recipe_lists).where(status: "published").where.not(origin: "mama").where( :recipe_lists => { :recipe_list_type => "curated" } ).where.not( :recipe_lists => { :id => [581, 770, 585, 583, 584, 593, 594, 595, 766] } ) }


  after_create do
    # update to cloudinary
    self.upload_to_cloudinary
  end

  def search_data
    {
      title: title,
      ingredients: ingredients
    }
  end

  def self.search_by_food(type, foods)
    return Recipe.where(status: "published").tagged_with(type).select { |r| (foods & r.foods).any? }.sort_by { |r| (foods & r.foods).count }.reverse
  end

  def upload_to_cloudinary
    if Rails.env.production? && self.image_url.present?
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

  def add_recipe_to_list(list_id)
    unless List.find(list_id).recipes.include?(self)
      RecipeListItem.create(recipe_id: self.id,
                          list_id: list_id,
                          name: self.title)
    end
  end

  def dismiss
    self.status = "dismissed"
    self.save
  end

  def publish
    self.status = "published"
    self.rate #save in rate method
  end

  def is_published?
    self.status == "published"
  end

  def is_user_favorite?(user)
    user.get_likes_recipe_list.recipes.pluck(:id).include?(self.id)
  end

  def is_selected?(recipe_list)
    recipe_list.recipes.pluck(:id).include?(self.id)
  end

  def is_disliked_by_user?(user)
    user.get_dislikes_recipe_list.recipes.pluck(:id).include?(self.id)
  end


  def get_best_store
    store_prices = []
    Store.all.each do |store|
      store_prices << [store.get_cheapest_cart_price(self.items)[0], store]
    end
    return store_prices.min
  end

  def sort_by_store_sections
    store_sections = StoreSection.order(:position).pluck(:name)
    store_sections << "Non-alimentaires"
    data = Hash[store_sections.map {|x| [x, Array.new]}]

    self.items.each do |item|
      if item.get_store_section.present?
        section = item.get_store_section.name
        data[section] << item
      end
    end

    return data
  end

  def get_store_section_items(store_section)
     Item.where(is_deleted: false,
               recipe_id: self.id,
               store_section_id: store_section.id)
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

  def good?
    return self.tag_list.include?("good")
  end

  def limit?
    return self.tag_list.include?("limit")
  end

  def get_curated_lists
    self.recipe_lists.where(recipe_list_type: "curated")
  end

  def get_curated_recipe_list_items
    self.recipe_list_items.select{ |rli| rli.is_curated?} if self.recipe_list_items.any?
  end

  def add_to_favorites(user)
    recipe_list = user.get_likes_recipe_list
    self.add_to_recipe_list(recipe_list)
  end

  def dislike_recipe(user)
    dislikes_recipe_list = user.get_dislikes_recipe_list
    self.add_to_recipe_list(dislikes_recipe_list)
  end

  def self.multi_search(query)
    search_queries = []
    recipes = []
    query.each do |q|
      search_queries << Recipe.where(status: "published").search(q, fields: [:title, :ingredients], execute: false)
      Category.find_by(name: q).subtree.each{ |c| recipes << c.recipes.where(status: "published") } if Category.find_by(name: q).present?
    end

    Searchkick.multi_search(search_queries)
    recipes << search_queries.map{ |search| search.results}

    results = recipes.flatten.group_by {|i| i}.sort_by {|_, a| -a.count}.map &:first

    return results.flatten
  end

  def self.get_disliked_recipe_ids
    RecipeListItem.where(recipe_list_id: RecipeList.where(recipe_list_type: "dislikes").pluck(:id)).pluck(:recipe_id)
  end

  def self.get_events(recipe_id)
    Ahoy::Event.where_properties(recipe_id: recipe_id)
  end

  def get_healthy_score
    good_bad_ratio = self.categories.where(rating: 1).count - self.categories.where(rating: 3).count
    score = good_bad_ratio / self.categories.size.to_f
    return score
  end

  def rate
    eligible_categories = self.categories.pluck(:id) - Category.get_seasonings
    rated_1 = self.categories.where(rating: 1) - Category.get_seasonings
    rated_3 = self.categories.where(rating: 3) - Category.get_seasonings
    good_bad_ratio = rated_1.count - rated_3.count
    score = good_bad_ratio / eligible_categories.size.to_f
    self.rating = score
    self.save
  end

  def self.recommend(category_ids, user)
    # get category data
    broad_category_ids = Category.find(category_ids).map{ |c| c.subtree.pluck(:id) }.flatten.compact
    # broad_category_ids = category_ids
    seasonings_ids = Category.get_seasonings
    # get curated recipe lists ids
    curated_list_ids = RecipeList.curated.pluck(:id) - [581, 770, 585, 583, 584, 593, 594, 595, 766]

    # select eligible recipes
    if broad_category_ids.any?
      recipe_ids = Recipe.curated.includes(:categories).where(categories: { id: broad_category_ids }).pluck(:id)
    else
      recipe_ids = Recipe.curated.pluck(:id).last(100)
    end

    user_disliked_recipe_ids = user.present? ? user.get_dislikes_recipe_list.recipes.pluck(:id) : Array.new

    eligible_recipe_ids = recipe_ids - user_disliked_recipe_ids


    # create recipe hash for good recipes
    recipe_hash = Recipe.where(id: eligible_recipe_ids)
                          .deep_pluck(:id, :link, :title, :rating, 'categories' => [:id, :rating], 'recipe_lists' => [:id])

    recipe_hash.each do |key, value|
      key["curated_category"] = (curated_list_ids & key["recipe_lists"].map{|x| x["id"]}).first

      user_impressions = user.present? ? Ahoy::Event.where(user_id: user.id, time: 1.day.ago..Time.now, name: "Recommend recipe").where_properties(recipe_id: key["id"]).count.to_f : 0
      # user capping decay
      user_impressions.to_i > 0 ? key["user_impressions_penalty"] = (0.5/ user_impressions.to_i) : key["user_impressions_penalty"] = 1

      key["cleaned_categories"] = key["categories"].map{|x| x["id"]} - seasonings_ids
      key["categories_used"] = (broad_category_ids & key["cleaned_categories"])
      key["nb_categories_used"] = key["categories_used"].size
      key["nb_categories"] = key["cleaned_categories"].size
      key["nb_categories_left"] = key["nb_categories"] - key["nb_categories_used"]

      key["nb_categories_used"] > 1 ? key["match_bonus"] = Math::acosh(key["nb_categories_used"]) : key["match_bonus"] = 1
      key["nb_categories_left"] > 0 ? key["categories_left_penalty"] = (0.9 / key["nb_categories_left"]) : key["categories_left_penalty"] = 1
      key["quality_score"] = key["nb_categories_used"] * key["categories_left_penalty"] * key["match_bonus"]

      # key["match_rate"] = (key["nb_categories_used"].to_f / key["nb_categories"].to_f)

      # key["fill_rate"] = (key["nb_categories_used"].to_f / category_ids.size.to_f ) * 0.3
      # key["fill_rate"] = 0.0 if key["fill_rate"].nan?
      key["random_score"] = (rand(-1.0..1.0).round(3) * 0.1)
      # key["healthy_rate"] = key["rating"] * 0.0

      key["score"] = key["quality_score"] + key["random_score"]
      key["score"] = (key["user_impressions_penalty"] * key["score"]) if key["user_impressions_penalty"].present?
    end

    # data << recipe_hash.sort_by! { |k| -k["score"] }
    # # merge hashes
    # recommendations = data.first.zip(data.second).flatten[0..[data.first.size, data.second.size].min]
    # return recommendations[0..99]

    # create an array of sorted recipe hashes for each curated category
    # data = recipe_hash.sort_by! { |k| -k["score"] }.group_by { |a| a["curated_category"] }.values
    # data = data.shuffle
    # results = data.first.zip(*data[1..]).flatten.compact
    results = recipe_hash.sort_by! { |k| -k["score"] }
    return results[0..99]
  end



  def scrape
    url = URI.parse("https://smartmama.herokuapp.com/api/v1/scrape?link=#{self.link}")
    # url = URI.parse("http://127.0.0.1:5000/api/v1/scrape?link=#{self.link}")

    unless JSON.parse(open(url).read) == "Website is not supported."
      parser = JSON.parse(open(url).read).first
      self.image_url = parser["image"]
      self.origin = parser["author"]
      self.origin = URI("#{self.link }").host if self.origin.nil?
      self.title = parser["name"].downcase.capitalize
      self.ingredients = parser["recipeIngredient"].join("\r\n")

      if parser["recipeInstructions"]
        parser["recipeInstructions"].class == "String" ? self.instructions = parser["recipeInstructions"] : self.instructions = parser["recipeInstructions"].join("\r\n")
      end

      self.servings = parser["recipeYield"]
      unless Recipe.find_by(title: self.title, origin: self.origin)
        self.save
      end
    end
  end

  # Import CSV
  def self.import(file)
    csv = CSV.read(file.path, headers: true)
    RecipeJob.perform_now(csv)
  end

  def should_generate_new_friendly_id?
    slug.blank? || title_changed?
  end

end

  # def self.import_csv(csv)

  #   unvalid_recipes = []

  #   Thread.new do
  #     csv.each do |row|

  #       data = row.to_h

  #       Recipe.find_by(link: data["url"]).nil? ? recipe = Recipe.new : recipe = Recipe.find_by(link: data["url"])

  #       recipe.title = data["name"].chars.select(&:valid_encoding?).join if data["name"]
  #       recipe.link = data["url"] if data["url"]

  #       # proceed with ingredients only if there is a value
  #       unless data["recipeIngredient"].empty?
  #         # rescue when single quotes in array that cant be eval
  #         begin
  #           recipe.ingredients = eval(data["recipeIngredient"]).join("\r\n").chars.select(&:valid_encoding?).join
  #         rescue SyntaxError
  #           recipe.ingredients = data["recipeIngredient"].gsub(/\'/, ' ')[1..-2].split(", ").map{|e| e.strip}.join("\r\n").chars.select(&:valid_encoding?).join
  #         end
  #         # if recipe had items, destroy so we do not generate duplicated items after save
  #         recipe.items.destroy_all if recipe.items.any?
  #       end

  #       if data["recipeInstructions"]
  #         unless data["recipeInstructions"].empty? || data["recipeInstructions"] == "[nan]"
  #           begin
  #             recipe.instructions = eval(data["recipeInstructions"]).join("\r\n").chars.select(&:valid_encoding?).join if data["recipeInstructions"]
  #           rescue SyntaxError
  #             recipe.instructions = data["recipeInstructions"].gsub(/\'/, ' ')[1..-2].split(", ").map{|e| e.strip}.join("\r\n").chars.select(&:valid_encoding?).join if data["recipeInstructions"]
  #           end
  #         end
  #       end

  #       recipe.servings = data["recipeYield"] if data["recipeYield"]
  #       recipe.image_url = eval(data["image"]).first if data["image"]
  #       recipe.origin =  data["author"] if data["author"]
  #       recipe.status = "pending"

  #       begin
  #         if recipe.save
  #           begin
  #             recipe.upload_to_cloudinary
  #             Item.add_recipe_items(recipe)
  #             puts "#{recipe.title}"
  #           rescue
  #             unvalid_recipes << data
  #             recipe.dismiss
  #           end
  #         else
  #           unvalid_recipes << data
  #         end
  #       rescue ActiveRecord::StatementInvalid
  #         unvalid_recipes << data
  #       end
  #     end

  #     if unvalid_recipes.any?
  #       puts "#{unvalid_recipes.size}"
  #       puts "#{unvalid_recipes}"
  #     end

  #   end
  # end
