class Recommendation < ApplicationRecord
  has_many :recipe_list_items
  has_many :recipes, through: :recipe_list_items

  # create a checklist of foods items
  def self.update_weekly_food_checklist
    checklist = []
    # exclude food that's not available in the given month
    food_pool = []
    current_month = Date.today.strftime("%m")
    Food.all.select do |food|
      food_pool << food if food.availability.include?(current_month)
    end
    # list foods by category
    vegetables = Category.find(14).foods & food_pool
    oelaginous = Category.find(15).foods & food_pool
    starches = (Category.find(20).foods + Category.find(21).foods) & food_pool
    legumes = Category.find(22).foods & food_pool
    delicatessen = Category.find(23).foods & food_pool
    fatty_fish = Category.find(25).foods & food_pool
    other_fish = Category.find(26).foods & food_pool
    meat = Category.find(27).foods & food_pool
    poultry = Category.find(28).foods & food_pool
    # build checklist with foods from category mix
    checklist << vegetables.shuffle.take(3)
    checklist << legumes.shuffle.take(2)
    checklist << poultry.shuffle.take(1)
    checklist << meat.shuffle.take(1)
    checklist << fatty_fish.shuffle.take(1)
    checklist << Food.find(30)
    return checklist = checklist.flatten
  end

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
  def get_recipe_candidates(recipes, checklist)
    candidates = []
    recipes.select do |r|
     if r.foods.any? { |f| checklist.include? f } then candidates << r end
    end
    candidates = candidates.sort_by{ |r| (checklist - (checklist - r.foods)).count }.reverse
  end

  # pick recipes in candidates list based on checklist constraints
  def pick_recipes(candidates)
    picks = []
    checks = []
    # put the first candidate in the list of picks & tick the checklist
    picks << candidates.first
    candidates.first.foods.each { |f| checks << f if @food_checklist.include? f }
    # repeat the process until the pick list is full
    until picks.count == 10 || (candidates - picks).count == 0
      new_pick = (candidates - picks).find { |r| ((@food_checklist - checks.uniq) & r.foods).any? }
      if new_pick
        picks << new_pick
        new_pick.foods.each { |f| checks << f if @food_checklist.include? f }
      else
        picks << (candidates - picks).first
      end
    end
  end

  def self.create_classic_basket(recommendation, recipe_pool, checklist)
    # set recipe list for classic basket
    list = RecipeList.find_by(name: "classique", recipe_list_type: "mama")
    # get list of proper recipes for classic basket
    all_recipes = recipe_pool.select { |r| r.tag_list.any? { |tag| ["rapide", "léger"].include?(tag) } }
    # exclude recipes from last week recommendation
    last_reco = Recommendation.where(recommendation_type: "classique").offset(1).last
    last_reco ? recipes = all_recipes - last_reco : recipes = all_recipes
    # select candidate recipes based on food checklist of the week
    candidates = get_recipe_candidates(recipes, checklist)
    # pick recipes for classic basket of the week
    picks = pick_recipes(candidates)
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
    last_reco ? recipes = all_recipes - last_reco : recipes = all_recipes
    # select candidate recipes based on food checklist of the week
    candidates = get_recipe_candidates(recipes, checklist)
    # pick recipes for classic basket of the week
    picks = pick_recipes(candidates)
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
    last_reco ? recipes = all_recipes - last_reco : recipes = all_recipes
    # select candidate recipes based on food checklist of the week
    candidates = get_recipe_candidates(recipes, checklist)
    # pick recipes for classic basket of the week
    picks = pick_recipes(candidates)
    # add picks to the corresponding recipe list
    picks.each do |recipe|
      RecipeListItem.create(recipe_id: recipe.id, recipe_list_id: list.id, position: 0, name: recipe.title, recommendation_id: recommendation.id)
    end
  end
end
