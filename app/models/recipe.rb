class Recipe < ApplicationRecord
  validates :title, :servings, :ingredients, :instructions, :status, :origin, presence: :true
  validates :title, uniqueness: :true
  has_many :items
  has_many :foods, through: :items
  has_many :cart_items, :as => :productable

  RATING = ["excellent", "good", "limit", "avoid"]

  acts_as_ordered_taggable

  searchkick

  def search_data
    {
      title: title,
      ingredients: ingredients,
      tags: tag_list,
      status: status
    }
  end
end
