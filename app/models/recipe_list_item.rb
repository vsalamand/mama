class RecipeListItem < ApplicationRecord
  belongs_to :recipe
  belongs_to :recipe_list
  belongs_to :recommendation
  validates :name, presence: :true
end
