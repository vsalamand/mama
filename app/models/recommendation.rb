class Recommendation < ApplicationRecord
  validates :recommendation_date, :daily_reco, presence: true
  validates :recommendation_date, uniqueness: true
end
