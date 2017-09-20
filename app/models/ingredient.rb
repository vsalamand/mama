class Ingredient < ApplicationRecord
  validates :name, uniqueness: true, presence: :true

  acts_as_taggable
end
