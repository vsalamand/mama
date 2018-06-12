class RecipeList < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :diet, optional: true

  validates :name, :recipe_list_type, presence: :true
  has_many :recipes, through: :recipe_list_items
  has_many :recipe_list_items

  RECIPE_LIST_TYPE = ["mama", "personal", "automated", "pool"]

end
