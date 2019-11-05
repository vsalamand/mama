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
end
