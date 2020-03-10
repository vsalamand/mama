class RecommendationItem < ApplicationRecord
  belongs_to :recommendation
  belongs_to :recipe_list, inverse_of: :recommendation_items

  accepts_nested_attributes_for :recipe_list

  # add name from recipe list
  after_create do
    if self.name.blank?
      self.get_name
    end
  end

  def get_name
    self.name = self.recipe_list.name
    self.save
  end
end
