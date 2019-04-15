class RecommendationItem < ApplicationRecord
  belongs_to :recommendation
  belongs_to :recipe_list, inverse_of: :recommendation_items

  accepts_nested_attributes_for :recipe_list

end
