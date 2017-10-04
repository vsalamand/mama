class Unit < ApplicationRecord
  validates :name, uniqueness: true, presence: :true
  has_many :items

end
