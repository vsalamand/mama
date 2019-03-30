class RecommendationItem < ApplicationRecord
  belongs_to :recommendation
  belongs_to :recipe_list
end
