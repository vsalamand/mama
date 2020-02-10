class StoreCartItem < ApplicationRecord
  belongs_to :store_cart
  belongs_to :store_item
  belongs_to :item
end
