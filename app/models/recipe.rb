class Recipe < ApplicationRecord
  validates :title, :servings, :ingredients, :instructions, presence: :true
  has_many :items

  acts_as_taggable

  searchkick

  def search_data
    {
      title: title,
      ingredients: ingredients,
      tags: tag_list,
      recommendable: recommendable
    }
  end
end
