class BannedCategory < ApplicationRecord
  validates :name, presence: true

  before_validation do
    self.name = self.category.name
  end

  belongs_to :food_group
  belongs_to :diet
end
