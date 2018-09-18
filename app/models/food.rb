class Food < ApplicationRecord
  validates :name, uniqueness: true, presence: :true
  has_many :items
  has_many :recipes, through: :items
  has_many :meta_recipe_items
  has_many :meta_recipes, through: :meta_recipe_items
  has_many :cart_items, :as => :productable
  belongs_to :category
  has_many :banned_foods
  has_many :diets, through: :banned_foods

  acts_as_ordered_taggable
  has_ancestry
  searchkick

  def search_data
    {
      name: name,
      tags: tag_list,
    }
  end

  def parent_enum
    Food.where.not(id: id).map { |f| [ f.name, f.id ] }
  end
end
