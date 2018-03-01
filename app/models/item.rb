class Item < ApplicationRecord
  # validates :ingredient_id, presence: true
  # validates :ingredient_id, uniqueness: { scope: [:recipe_id, :unit_id] }

  belongs_to :food, optional: true
  belongs_to :recipe
  belongs_to :unit, optional: true
end
