class RecipeList < ApplicationRecord
  belongs_to :user, optional: true

  # validates :name, :recipe_list_type, presence: :true
  has_many :recipes, through: :recipe_list_items
  has_many :items, through: :recipes
  has_many :recipe_list_items, dependent: :destroy, inverse_of: :recipe_list
  has_many :foods, through: :recipes
  has_many :recommendation_items, dependent: :destroy, inverse_of: :recipe_list
  has_many :recommendations, through: :recommendation_items


  accepts_nested_attributes_for :recipe_list_items, allow_destroy: true
  accepts_nested_attributes_for :recommendation_items

  acts_as_ordered_taggable

  scope :curated, -> { where(recipe_list_type: "curated") }


  RECIPE_LIST_TYPE = ["curated", "mama", "personal", "pool"]
  STATUS = ["archived", "saved", "opened"]

  # after_create_commit :get_name
  after_update_commit :get_name


  def get_name
    if self.name.blank?
      self.name = self.get_top_foods[0..6].join(", ")
      self.save
    end
  end

  def archive
    self.status = "archived"
    self.save
  end

  def is_saved
    self.name = "Menu du #{Date.today.strftime("%d/%m/%y")}" if self.name.blank?
    self.status = "saved"
    self.save
  end

  def get_top_foods
    # create hash of food roots sorted by count, and return a list of food names sorted by count
    foodlist = self.foods - Food.get_condiment_food
    return Hash[foodlist.group_by{|x| x.root}.map {|k,v| [k, v.size] }.sort_by {|k, v| v}.reverse].keys.flatten.map(&:name)
  end

  def get_description
    # foodlist = self.foods.distinct.sort_by { |f| f.category_id }.map { |food| food.name if food.shelf_list != ["épicerie"]}.compact
    self.description = self.get_top_foods.join(", ")
    self.save
  end

  def self.get_curated_recipes
    latest_curated_recipes = []
    RecipeList.where(recipe_list_type: "curated").last(3).each{ |recipe_list| latest_curated_recipes << recipe_list.recipes }
    return latest_curated_recipes.flatten.uniq.reverse
  end

  def clean
    if self.recipe_list_items.any? && self.status == "opened"
      self.recipe_list_items.destroy_all
    end
  end

  def get_recipe_list_item_id(recipe_id)
    return RecipeListItem.find_by(recipe_id: recipe_id, recipe_list_id: self.id).id
  end
end
