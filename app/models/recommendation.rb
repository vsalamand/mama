class Recommendation < ApplicationRecord
  has_many :recipe_list_items
  has_many :recipes, through: :recipe_list_items

  # exclude recipes when they contain food that's not available in the given month
  def self.update_recipe_pools
    seasonal_foods = FoodList.find_by(name: "seasonal foods", food_list_type: "pool")
    available_recipes = Recipe.where(status: "published").select { |recipe| (recipe.foods - seasonal_foods.foods).empty? }
    # List all recipes that should be exclude from any diet
    unavailable_recipes = Recipe.all - available_recipes

    # for each diet, list all recipes that contain only seasonal food and exclude any food not approved by the diet
    Diet.all.each do |diet|
      # Get the diet recipe list
      seasonal_recipes = RecipeList.find_by(diet_id: diet.id, recipe_list_type: "pool")
      #!!! delete recipe items in the list when they've become no longer seasonal
      seasonal_recipes.recipe_list_items.each do |recipe_item|
        recipe_item.destroy if unavailable_recipes.include?(recipe_item.recipe)
      end
      # Get the new list of recipes that exclude foods banned for the diet
      banned_foods = FoodList.find_by(diet_id: diet.id, food_list_type: "ban")
      new_diet_recipes = available_recipes.select { |recipe| (recipe.foods & banned_foods.foods).empty? }
      # then add new seasonal/published recipes to the list
      new_diet_recipes.each do |recipe|
        RecipeListItem.find_or_create_by(name: recipe.title, recipe_id: recipe.id, recipe_list_id: seasonal_recipes.id)
      end
    end
  end

  # get list of recipes sort by nb of foods
  def self.get_candidates(recommendation, diet, type)
    # list food and food children from checklist (ancestry gem)
    food_list = []
    checklist = Checklist.find_by(diet_id: diet.id)
    # for each food, get the food children and verify category and availability
    checklist.foods.each { |food| food_list << food.subtree.where(category: food.category).where("availability ~ ?", Date.today.strftime("%m")) }
    food_list = food_list.flatten

    # get list of the diet recipes that correspond to the right type of bucket
    recipe_list = RecipeList.find_by(diet_id: diet.id, recipe_list_type: "pool").recipes.select{ |r| r.tag_list.any? { |tag| type.include?(tag) } }
    # exclude recipes from last week recommendation if any
    last_reco = Recommendation.find_by(diet_id: diet.id, recommendation_type: type)
    last_reco.present? ? eligible_recipes = recipe_list - last_reco.recipes : eligible_recipes = recipe_list

    # find recipes that include at least one of the food in the list
    candidates = []
    eligible_recipes.select do |r|
      if r.foods.any? { |food| food_list.include? food }
        then candidates << r
      end
    end
    return candidates = candidates.sort_by{ |r| (food_list - (food_list - r.foods)).count }.reverse
  end

  # pick recipes in candidates list based on checklist constraints
  def self.pick_candidates(candidates, diet)
    checklist = Checklist.find_by(diet_id: diet.id)
    picks = []
    checks = []
    # put the first candidate in the list of picks & tick the checklist
    picks << candidates.first
    # tick food that's in the checklist
    checklist.foods.each do |food|
      checks << food if (food.subtree.where(category: food.category).where("availability ~ ?", Date.today.strftime("%m")) & candidates.first.foods).any?
    end
    # repeat the process until the pick list is full
    until picks.count == 10 || (candidates - picks).count == 0
      new_pick = (candidates - picks).find { |r| ((checklist.foods - checks.uniq) & r.foods).any? }
      if new_pick
        picks << new_pick
        checklist.foods.each do |food|
          checks << food if (food.subtree.where(category: food.category).where("availability ~ ?", Date.today.strftime("%m")) & new_pick.foods).any?
        end
      else
        picks << (candidates - picks).first
      end
    end
    return picks
  end
end
