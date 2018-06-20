class RecipeList < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :diet, optional: true

  validates :name, :recipe_list_type, presence: :true
  has_many :recipes, through: :recipe_list_items
  has_many :recipe_list_items

  RECIPE_LIST_TYPE = ["mama", "personal", "recommendation", "pool", "ban", "history"]

  def self.add_to_user_history(user, recipe)
    weekly_menu = RecipeList.find_by(name: "Weekly menu", user_id: user.id, recipe_list_type: "recommendation")
    user_history = RecipeList.find_or_create_by(name: "Weekly menu history", user_id: user.id, recipe_list_type: "history")
    recipe_item = RecipeListItem.find_by(recipe_list_id: weekly_menu.id, recipe_id: recipe.id)
    recipe_item.recipe_list_id = user_history.id
    recipe_item.save
  end

  def self.ban_recipe(user, recipe)
    weekly_menu = RecipeList.find_by(name: "Weekly menu", user_id: user.id, recipe_list_type: "recommendation")
    user_banned_list = RecipeList.find_or_create_by(name: "Banned recipes", user_id: user.id, recipe_list_type: "ban")
    recipe_item = RecipeListItem.find_by(recipe_list_id: weekly_menu.id, recipe_id: recipe.id)
    recipe_item.recipe_list_id = user_banned_list.id
    recipe_item.save
  end
end
