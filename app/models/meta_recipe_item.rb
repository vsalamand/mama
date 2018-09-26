class MetaRecipeItem < ApplicationRecord
  belongs_to :meta_recipe
  belongs_to :food, optional: true
end
