class Product < ApplicationRecord
  belongs_to :food, optional: true
  belongs_to :unit, optional: true
  validates :ean, uniqueness: true
  has_many :store_items
  has_many :stores, through: :store_items
  has_many :merchants, through: :stores

  def self.get_products_without_foods
    return Product.where(food_id: nil)
  end
end
