class MetaRecipeListItem < ApplicationRecord
  belongs_to :meta_recipe_list
  belongs_to :meta_recipe
end
