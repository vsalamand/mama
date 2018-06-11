class Diet < ApplicationRecord
  validates :name, presence: :true
  has_many :food_lists
  has_many :checklists
  has_many :recipe_lists
  has_many :recommendations
end
