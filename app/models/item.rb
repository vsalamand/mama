class Item < ApplicationRecord
  belongs_to :ingredient
  belongs_to :recipe
  belongs_to :unit
end
