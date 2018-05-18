class FoodList < ApplicationRecord
  belongs_to :user
  validates :name, :food_list_type, :user_id, presence: :true
  has_many :foods, through: :food_list_items
  has_many :food_list_items

  FOOD_LIST_TYPE = ["mama", "personal"]

end
