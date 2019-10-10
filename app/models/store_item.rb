class StoreItem < ApplicationRecord
  belongs_to :product
  belongs_to :store
  has_many :store_item_histories, dependent: :destroy
  has_one :food, through: :product
  has_many :cart_items, :as => :productable
  has_one :unit, through: :product

  def get_best_price
    best_price = self.is_promo ? self.price * (self.promo_price_per_unit / self.price_per_unit) : self.price
    return sprintf("%.2f", best_price)
  end

  def self.get_cheap_store_items(foods)
    cheap_store_items = []
    foods.each{ |food| cheap_store_items << food.get_cheapest_store_item }
    return cheap_store_items.reject(&:blank?)
  end
end
