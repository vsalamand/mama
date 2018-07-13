class Category < ApplicationRecord
  # attr_accessible :name, :parent_id
  has_ancestry
  has_many :foods
  has_many :banned_categories
  has_many :diets, through: :banned_categories

  RATING = ["good", "limit", "avoid"]

  def parent_enum
    Category.where.not(id: id).map { |c| [ c.name, c.id ] }
  end
end
