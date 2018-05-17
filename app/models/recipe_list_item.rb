class RecipeListItem < ApplicationRecord
  belongs_to :recipe
  belongs_to :recipe_list, optional: true
  belongs_to :recommendation, optional: true
  validates :name, presence: :true
end
