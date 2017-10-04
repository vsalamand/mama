class Unit < ApplicationRecord
  validates :name, uniqueness: true, presence: :true
end
