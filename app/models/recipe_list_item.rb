class RecipeListItem < ApplicationRecord
  belongs_to :recipe
  belongs_to :recipe_list
  acts_as_list scope: :recipe_list
  validates :name, presence: :true
end
