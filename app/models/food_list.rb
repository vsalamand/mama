class FoodList < ApplicationRecord
  belongs_to :user
  validates :name, :food_list_type, :user_id, presence: :true

  FOOD_LIST_TYPE = ["mama", "personal"]

end
