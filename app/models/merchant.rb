class Merchant < ApplicationRecord
  has_many :stores
  # has_many :store_items, through: :stores
  # has_many :products, through: :store_items
  # has_many :foods, through: :products
end
