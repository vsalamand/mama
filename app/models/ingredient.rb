class Ingredient < ApplicationRecord
  validates :name, uniqueness: true, presence: :true
  has_many :items

  acts_as_ordered_taggable

  searchkick

end
