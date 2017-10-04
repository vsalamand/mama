class Item < ApplicationRecord
  validates :ingredient_id, presence: true

  belongs_to :ingredient
  belongs_to :recipe, optional: true
  belongs_to :unit, optional: true
end
