class Food < ApplicationRecord
  validates :name, uniqueness: true, presence: :true
  has_many :items
  has_many :recipes, through: :items
  has_many :cart_items, :as => :productable
  belongs_to :category

  acts_as_ordered_taggable
  has_ancestry
  searchkick

  def parent_enum
    Food.where.not(id: id).map { |f| [ f.name, f.id ] }
  end
end
