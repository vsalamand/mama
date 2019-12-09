class Product < ApplicationRecord
  belongs_to :food, optional: true
  belongs_to :unit, optional: true
  validates :ean, uniqueness: true
  has_many :store_items, dependent: :destroy
  has_many :stores, through: :store_items
  has_many :merchants, through: :stores
  has_many :cart_items, :as => :productable

  searchkick


  def search_data
    {
      name: name,
      brand: brand
    }
  end


  def self.get_products_without_foods
    return Product.where(food_id: nil)
  end

  def report
    self.is_reported = true
    self.save
  end

  def get_related_products
    related_products = self.food.products - Array(self)
    return related_products
  end

  def get_cheapest_store_item
    return StoreItem.find(self.store_items.pluck(:price_per_unit, :id, :store_id).min.second)
  end

  def get_related_recipes
    return self.food.recipes.reverse[0..9]
  end
end
