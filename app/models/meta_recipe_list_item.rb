class MetaRecipeListItem < ApplicationRecord
  belongs_to :meta_recipe_list
  belongs_to :meta_recipe, inverse_of: :meta_recipe_list_items
  has_many :meta_recipe_items, through: :meta_recipe

  accepts_nested_attributes_for :meta_recipe

  # add name from meta recipe
  after_create do
    self.get_name
  end

  # find all recipes with the parent meta recipe and add the new tag
  before_save do
    self.add_new_tag if self.meta_recipe_list.list_type == "pool" && self.changed?
  end

  # # find all recipes with the parent meta recipe and remove the tag if no other meta recipe has it
  # before_destroy do
  # end

  def get_name
    self.name = self.meta_recipe.name
    self.save
  end

  def get_tags
    tags = self.meta_recipe.meta_recipe_lists.where(list_type: "pool").map do |pool|
      pool.name
    end
    return tags
  end

  def add_new_tag
    tag = self.meta_recipe_list.name
    mrl_recipes = self.meta_recipe.meta_recipe_lists.where(list_type: "recipe")
    if mrl_recipes.any?
      mrl_recipes.each do |mrl|
        mrl.recipe.tag_list.add(tag)
        mrl.recipe.save
      end
    end
  end

end
