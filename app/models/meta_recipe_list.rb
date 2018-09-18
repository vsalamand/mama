class MetaRecipeList < ApplicationRecord
  belongs_to :recipe
  validates :name, presence: :true, uniqueness: :true
end
