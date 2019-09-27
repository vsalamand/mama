class StoreItem < ApplicationRecord
  belongs_to :product
  belongs_to :store
  has_many :store_item_histories, dependent: :destroy
end
