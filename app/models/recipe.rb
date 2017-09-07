class Recipe < ApplicationRecord
  validates :title, :servings, :ingredients, :instructions, presence: :true
end
