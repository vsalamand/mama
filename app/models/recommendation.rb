class Recommendation < ApplicationRecord
  belongs_to :user
  validates :name, :date, :user_id, presence: :true
  has_many :recipe_lists, through: :recommendation_items
  has_many :recommendation_items, dependent: :destroy, inverse_of: :recommendation

  accepts_nested_attributes_for :recommendation_items, allow_destroy: true
end
