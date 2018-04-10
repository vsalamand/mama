class RecipeList < ApplicationRecord
  belongs_to :user
  validates :name, :type, :user_id, presence: :true
  has_many :recipe_list_items, -> { order(position: :asc) }

  RECIPE_LIST_TYPE = ["mama", "personal", "automated"]

end
