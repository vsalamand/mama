class Product < ApplicationRecord
  belongs_to :food
  belongs_to :unit
end
