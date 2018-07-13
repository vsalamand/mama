class BannedFood < ApplicationRecord
  validates :name, presence: true

  before_validation do
    self.name = self.food.name
  end

  belongs_to :diet
  belongs_to :food
end
