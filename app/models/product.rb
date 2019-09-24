class Product < ApplicationRecord
  belongs_to :food, optional: true
  belongs_to :unit, optional: true
end
