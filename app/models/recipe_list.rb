class RecipeList < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :diet, optional: true

  validates :name, :recipe_list_type, presence: :true
  has_many :recipes, through: :recipe_list_items
  has_many :recipe_list_items, dependent: :destroy, inverse_of: :recipe_list
  has_many :foods, through: :recipes
  has_many :recommendation_items, dependent: :destroy, inverse_of: :recipe_list
  has_many :recommendations, through: :recommendation_items


  accepts_nested_attributes_for :recipe_list_items, allow_destroy: true
  accepts_nested_attributes_for :recommendation_items


  RECIPE_LIST_TYPE = ["curated", "mama", "personal", "pool",]


  def get_description
    foodlist = self.foods.uniq.sort_by { |f| f.category_id }.map { |food| food.name if food.shelf_list != ["épicerie"]}.compact
    self.description = foodlist.join(", ")
    self.save
  end

  def get_top_foods
    # create hash of food roots sorted by count, and return a list of food names sorted by count
    foodlist = Hash[self.foods.group_by{|x| x.root}.map {|k,v| [k, v.size] }.sort_by {|k, v| v}.reverse].keys.flatten.map(&:name)
  end

end
