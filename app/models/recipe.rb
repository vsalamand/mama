class Recipe < ApplicationRecord
  validate :title, :servings, :ingredients, :instructions, presence: :true
end
