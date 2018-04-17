class RecipeList < ApplicationRecord
  belongs_to :user
  validates :name, :recipe_list_type, :user_id, presence: :true
  has_many :recipes, through: :recipe_list_items
  has_many :recipe_list_items

  RECIPE_LIST_TYPE = ["mama", "personal", "automated"]

end
