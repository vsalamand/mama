class RecipeList < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :diet, optional: true

  validates :name, :recipe_list_type, presence: :true
  has_many :recipes, through: :recipe_list_items
  has_many :recipe_list_items, dependent: :destroy
  has_many :foods, through: :recipes

  RECIPE_LIST_TYPE = ["mama", "personal", "recommendation", "pool", "ban", "history"]

  def self.add_to_user_history(user, recipe)
    weekly_menu = RecipeList.find_by(name: "Weekly menu", user_id: user.id, recipe_list_type: "recommendation")
    user_history = RecipeList.find_or_create_by(name: "History", user_id: user.id, recipe_list_type: "history")
    recipe_item = RecipeListItem.find_by(recipe_list_id: weekly_menu.id, recipe_id: recipe.id)
    unless recipe_item.nil?
      recipe_item.recipe_list_id = user_history.id
      recipe_item.save
    end
  end

  def self.ban_recipe(user, recipe)
    weekly_menu = RecipeList.find_by(name: "Weekly menu", user_id: user.id, recipe_list_type: "recommendation")
    user_banned_list = RecipeList.find_or_create_by(name: "Banned recipes", user_id: user.id, recipe_list_type: "ban")
    recipe_item = RecipeListItem.find_by(recipe_list_id: weekly_menu.id, recipe_id: recipe.id)
    recipe_item.recipe_list_id = user_banned_list.id
    recipe_item.save
  end

  def self.update_recipe_pools
    seasonal_foods = FoodList.find_by(name: "seasonal foods", food_list_type: "pool")
    available_recipes = Recipe.where(status: "published").select { |recipe| (recipe.foods - seasonal_foods.foods).empty? }
    # List all recipes that should be exclude from any diet
    unavailable_recipes = Recipe.all - available_recipes

    # for each diet, list all recipes that contain only seasonal food and exclude any food not approved by the diet
    Diet.all.each do |diet|
      # Get the diet recipe list
      seasonal_recipes = RecipeList.find_by(diet_id: diet.id, recipe_list_type: "pool")
      banned_foods = FoodList.find_by(diet_id: diet.id, food_list_type: "ban")
      #!!! delete recipe items in the list when they've become no longer seasonal
      seasonal_recipes.recipe_list_items.each do |recipe_item|
        recipe_item.destroy if unavailable_recipes.include?(recipe_item.recipe) || (recipe_item.recipe.foods & banned_foods.foods).any?
      end
      # Get the new list of recipes that exclude foods banned for the diet
      new_diet_recipes = available_recipes.select { |recipe| (recipe.foods & banned_foods.foods).empty? }
      # then add new seasonal/published recipes to the list
      new_diet_recipes.each do |recipe|
        RecipeListItem.find_or_create_by(name: recipe.title, recipe_id: recipe.id, recipe_list_id: seasonal_recipes.id)
      end
    end
  end

end
