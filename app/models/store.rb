class Store < ApplicationRecord
  belongs_to :merchant
  has_many :store_items
  has_many :products, through: :store_items
  has_many :foods, through: :products

  STORE_TYPE = ["online", "physical"]

end
