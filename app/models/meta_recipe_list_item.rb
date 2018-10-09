class MetaRecipeListItem < ApplicationRecord
  belongs_to :meta_recipe_list
  belongs_to :meta_recipe, inverse_of: :meta_recipe_list_items

  accepts_nested_attributes_for :meta_recipe

  # add name from meta recipe
  after_create do
    self.name = self.meta_recipe.name
    self.save
  end

  def get_tags
    tags = self.meta_recipe.meta_recipe_lists.where(list_type: "pool").map do |pool|
      pool.name
    end
    return tags
  end

end
