class RecipeListItem < ApplicationRecord
  belongs_to :recipe, inverse_of: :recipe_list_items
  belongs_to :recipe_list, optional: true
  belongs_to :list, optional: true

  accepts_nested_attributes_for :recipe

  # add name from recipe title
  after_create do
    if self.name.blank?
      self.get_name
    end
  end

  def get_name
    self.name = self.recipe.title
    self.save
  end

  def self.get_most_popular
    RecipeListItem.where.not(list_id: nil).pluck(:recipe_id)
                                .group_by{|x| x}.sort_by{|k, v| -v.size}.map(&:first)[0..29]
                                .map{ |r_id| Recipe.find(r_id) }
  end

end
