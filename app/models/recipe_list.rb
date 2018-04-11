class RecipeList < ApplicationRecord
  belongs_to :user
  validates :name, :type, :user_id, presence: :true
  has_many :recipe_list_items, -> { order(position: :asc) }
  has_many :recipes, through: :recipe_list_items

  RECIPE_LIST_TYPE = ["mama", "personal", "automated"]

end
