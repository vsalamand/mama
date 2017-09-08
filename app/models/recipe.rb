class Recipe < ApplicationRecord
  validates :title, :servings, :ingredients, :instructions, presence: :true

  acts_as_taggable
end
