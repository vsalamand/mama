class Category < ApplicationRecord
  # attr_accessible :name, :parent_id
  has_ancestry
  has_many :foods

  def parent_enum
    Category.where.not(id: id).map { |c| [ c.name, c.id ] }
  end
end
