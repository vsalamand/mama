class Food < ApplicationRecord
  validates :name, uniqueness: true, presence: :true
  has_many :items
  has_many :recipes, through: :items
  belongs_to :category

  acts_as_ordered_taggable

  searchkick

end
