class Recommendation < ApplicationRecord
  validates :recommendation_date, :daily_reco, presence: true
end
