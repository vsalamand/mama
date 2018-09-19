class MetaRecipeListItem < ApplicationRecord
  belongs_to :meta_recipe_list
  belongs_to :meta_recipe

  # add name from meta recipe
  after_create do
    self.name = self.meta_recipe.name
    self.save
  end

end
