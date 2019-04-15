class RecipeListItem < ApplicationRecord
  belongs_to :recipe, inverse_of: :recipe_list_items

  belongs_to :recipe_list, optional: true

  accepts_nested_attributes_for :recipe

  # add name from recipe title
  after_create do
    self.get_name
  end

  def get_name
    self.name = self.recipe.title
    self.save
  end

end
