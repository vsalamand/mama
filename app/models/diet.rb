class Diet < ApplicationRecord
  validates :name, presence: :true
  has_many :food_lists
  has_many :checklists
  has_many :users
  has_many :banned_categories
  has_many :categories, through: :banned_categories
  has_many :banned_foods
  has_many :foods, through: :banned_foods

end
