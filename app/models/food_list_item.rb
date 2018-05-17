class FoodListItem < ApplicationRecord
  belongs_to :food
  belongs_to :food_list, optional: true
  belongs_to :checklist, optional: true
  validates :name, presence: :true
end
