class Recommendation < ApplicationRecord
  has_many :recipe_list_items
  has_many :recipes, through: :recipe_list_items

  # exclude recipes when they contain food that's not available in the given month
  def self.update_recipe_pool
    recipe_pool = []
    current_month = Date.today.strftime("%m")
    Recipe.all.select do |recipe|
      unless recipe.foods.find { |food| food.availability.exclude?(current_month)} || recipe.status != "published"
        recipe_pool << recipe
      end
    end
    return recipe_pool
  end

  # get list of recipes sort by nb of foods
  def self.get_recipe_candidates(recipes, checklist)
    # list food and food children from checklist (ancestry gem)
    food_list = []
    checklist.foods.each { |f| food_list << f.subtree.where(category: f.category) }
    food_list = food_list.flatten
    # find recipes that include at least one of the food in the list
    candidates = []
    recipes.select do |r|
      if r.foods.any? { |f| food_list.foods.include? f }
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
    candidates.first.foods.each { |f| checks << f if checklist.foods.include? f }
    # repeat the process until the pick list is full
    until picks.count == 10 || (candidates - picks).count == 0
      new_pick = (candidates - picks).find { |r| ((checklist.foods - checks.uniq) & r.foods).any? }
      if new_pick
        picks << new_pick
        new_pick.foods.each { |f| checks << f if checklist.foods.include? f }
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
