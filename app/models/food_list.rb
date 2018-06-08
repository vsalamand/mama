class FoodList < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :diet, optional: true

  validates :name, :food_list_type, presence: :true
  has_many :foods, through: :food_list_items
  has_many :food_list_items

  FOOD_LIST_TYPE = ["recommendation", "ban", "personal"]

end
