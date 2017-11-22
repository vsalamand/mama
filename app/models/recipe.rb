class Recipe < ApplicationRecord
  validates :title, :servings, :ingredients, :instructions, :status, :origin, presence: :true
  validates :title, uniqueness: :true
  has_many :items

  acts_as_taggable

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
