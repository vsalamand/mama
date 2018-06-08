class Recommendation < ApplicationRecord
  has_many :recipe_list_items
  has_many :recipes, through: :recipe_list_items

  # exclude recipes when they contain food that's not available in the given month
  def self.update_recipe_pools
    # find recipes that contain food not available in the given month
    available_date = Date.today.strftime("%m")
    seasonal_foods = FoodList.find_by(name: "seasonal foods", food_list_type: "pool")


    available_recipes = []
    Recipe.where(status: "published").select { |recipe| availble_recipes << recipe if (recipe.foods - seasonal_foods.foods).empty? }

    unavailable_recipes = Recipe.all - available_recipes



    Diet.where(is_active: true).each do |diet|
      #Update the diet recipe list
      seasonal_recipes = RecipeList.find_by(diet_id: diet.id, recipe_list_type: "pool")


      #!!! delete recipe items in the list when they are no longer seasonal
      seasonal_recipes.recipe_list_items.each do |recipe_item|
        recipe_item.destroy if unavailable_recipes.include?(recipe_item.recipe)
      end

      # then add new seasonal/published recipes to the list
      Recipe.where(status: "published").each do |recipe|
        RecipeListItem.find_or_create_by(name: recipe.title, recipe_id: recipe.id, recipe_list_id: seasonal_recipes.id)
      end


      # recipe_pool = []
      # current_month = Date.today.strftime("%m")
      # Recipe.all.select do |recipe|
      #   unless recipe.foods.find { |food| food.availability.exclude?(current_month)} || recipe.status != "published"
      #     recipe_pool << recipe
      #   end
      # end
      # return recipe_pool
    end
  end

  # get list of recipes sort by nb of foods
  def self.get_recipe_candidates(recipes, checklist)
    # list food and food children from checklist (ancestry gem)
    food_list = []
      # for each food, get the food children and verify category and availability
    checklist.foods.each { |food| food_list << food.subtree.where(category: food.category).where("availability ~ ?", Date.today.strftime("%m")) }
    food_list = food_list.flatten
    # find recipes that include at least one of the food in the list
    candidates = []
    recipes.select do |r|
      if r.foods.any? { |food| food_list.include? food }
        then candidates << r
      end
    end
    return candidates = candidates.sort_by{ |r| (food_list - (food_list - r.foods)).count }.reverse
  end

  # pick recipes in candidates list based on checklist constraints
  def self.pick_recipes(candidates, checklist)
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

  def self.create_balanced_basket(recommendation, recipe_pool, checklist)
    # set recipe list for classic basket
    list = RecipeList.find_by(name: "équilibré", recipe_list_type: "mama")
    # get list of proper recipes for classic basket
    all_recipes = recipe_pool.select { |r| r.tag_list.any? { |tag| ["rapide", "léger"].include?(tag) } }
    # exclude recipes from last week recommendation
    last_reco = Recommendation.where(recommendation_type: "équilibré").offset(1).last
    last_reco.present? ? recipes = all_recipes - last_reco.recipes : recipes = all_recipes
    # select candidate recipes based on food checklist of the week
    candidates = Recommendation.get_recipe_candidates(recipes, checklist)
    # pick recipes for classic basket of the week
    picks = Recommendation.pick_recipes(candidates, checklist)
    # add picks to the corresponding recipe list
    picks.each do |recipe|
      RecipeListItem.create(recipe_id: recipe.id, recipe_list_id: list.id, position: 0, name: recipe.title, recommendation_id: recommendation.id)
    end
  end

  def self.create_express_basket(recommendation, recipe_pool, checklist)
    # set recipe list for classic basket
    list = RecipeList.find_by(name: "express", recipe_list_type: "mama")
    # get list of proper recipes for classic basket
    all_recipes = recipe_pool.select { |r| r.tag_list.any? { |tag| ["snack", "tarte salée"].include?(tag) } }
    # exclude recipes from last week recommendation
    last_reco = Recommendation.where(recommendation_type: "express").offset(1).last
    last_reco.present? ? recipes = all_recipes - last_reco.recipes : recipes = all_recipes
    # select candidate recipes based on food checklist of the week
    candidates = Recommendation.get_recipe_candidates(recipes, checklist)
    # pick recipes for classic basket of the week
    picks = Recommendation.pick_recipes(candidates, checklist)
    # add picks to the corresponding recipe list
    picks.each do |recipe|
      RecipeListItem.create(recipe_id: recipe.id, recipe_list_id: list.id, position: 0, name: recipe.title, recommendation_id: recommendation.id)
    end
  end

  def self.create_gourmand_basket(recommendation, recipe_pool, checklist)
    # set recipe list for classic basket
    list = RecipeList.find_by(name: "gourmand", recipe_list_type: "mama")
    # get list of proper recipes for classic basket
    all_recipes = recipe_pool.select { |r| r.tag_list.any? { |tag| ["gourmand"].include?(tag) } }
    # exclude recipes from last week recommendation
    last_reco = Recommendation.where(recommendation_type: "gourmand").offset(1).last
    last_reco.present? ? recipes = all_recipes - last_reco.recipes : recipes = all_recipes
    # select candidate recipes based on food checklist of the week
    candidates = Recommendation.get_recipe_candidates(recipes, checklist)
    # pick recipes for classic basket of the week
    picks = Recommendation.pick_recipes(candidates, checklist)
    # add picks to the corresponding recipe list
    picks.each do |recipe|
      RecipeListItem.create(recipe_id: recipe.id, recipe_list_id: list.id, position: 0, name: recipe.title, recommendation_id: recommendation.id)
    end
  end
end
