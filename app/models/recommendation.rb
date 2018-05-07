class Recommendation < ApplicationRecord
  has_many :recipe_list_items
  has_many :recipes, through: :recipe_list_items

  # exclude food that's not available in the given month
  def self.update_food_pools
    @food_pool = []
    current_month = Date.today.strftime("%m")
    Food.all.select do |food|
      @food_pool << food if food.availability.include?(current_month)
    end
    @vegetable_pool = Category.find(14).foods & @food_pool
    @oelaginous_pool = Category.find(15).foods & @food_pool
    @starch_pool = (Category.find(20).foods + Category.find(21).foods) & @food_pool
    @legume_pool = Category.find(22).foods & @food_pool
    @delicatessen_pool = Category.find(23).foods & @food_pool
    @fatty_fish_pool = Category.find(25).foods & @food_pool
    @other_fish_pool = Category.find(26).foods & @food_pool
    @meat_pool = Category.find(27).foods & @food_pool
    @poultry_pool = Category.find(28).foods & @food_pool
  end

  # create a checklist of foods items
  def self.update_weekly_food_checklist
    @food_checklist = []
    @food_checklist << @vegetable_pool.shuffle.take(3)
    @food_checklist << @legume_pool.shuffle.take(2)
    @food_checklist << @poultry_pool.shuffle.take(1)
    @food_checklist << @meat_pool.shuffle.take(1)
    @food_checklist << @fatty_fish_pool.shuffle.take(1)
    @food_checklist << Food.find(30)
    @food_checklist = @food_checklist.flatten
  end

  # exclude recipes when they contain food that's not available in the given month
  def self.update_recipe_pool
    @recipe_pool = []
    current_month = Date.today.strftime("%m")
    Recipe.all.select do |recipe|
      unless recipe.foods.find { |food| food.availability.exclude?(current_month)} || recipe.status != "published"
        @recipe_pool << recipe
      end
    end
  end

  # get list of recipes sort by nb of foods
  def get_checklist_candidates(recipes)
    candidates = []
    recipes.select do |r|
     if r.foods.any? { |f| @food_checklist.include? f } then candidates << r end
    end
    candidates = candidates.sort_by{ |r| (@food_checklist - (@food_checklist - r.foods)).count }.reverse
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

  def self.create_classic_basket(recommendation)
    # set recipe list for classic basket
    list = RecipeList.find_by(name: "classique", recipe_list_type: "mama")
    # get list of proper recipes for classic basket
    all_recipes = @recipe_pool.select { |r| r.tag_list.any? { |tag| ["rapide", "léger"].include?(tag) } }
    # exclude recipes from last week recommendation
    last_reco = Recommendation.where(recommendation_type: "classique").offset(1).last
    last_reco ? recipes = all_recipes - last_reco : recipes = all_recipes
    # select candidate recipes based on food checklist of the week
    candidates = get_checklist_candidates(recipes)
    # pick recipes for classic basket of the week
    picks = pick_recipes(candidates)
    # add picks to the corresponding recipe list
    picks.each do |recipe|
      RecipeListItem.create(recipe_id: recipe.id, recipe_list_id: list.id, position: 0, name: recipe.title, recommendation_id: recommendation.id)
    end
  end

  def self.create_express_basket(recommendation)
    # set recipe list for classic basket
    list = RecipeList.find_by(name: "express", recipe_list_type: "mama")
    # get list of proper recipes for classic basket
    all_recipes = @recipe_pool.select { |r| r.tag_list.any? { |tag| ["snack", "tarte salée"].include?(tag) } }
    # exclude recipes from last week recommendation
    last_reco = Recommendation.where(recommendation_type: "express").offset(1).last
    last_reco ? recipes = all_recipes - last_reco : recipes = all_recipes
    # select candidate recipes based on food checklist of the week
    candidates = get_checklist_candidates(recipes)
    # pick recipes for classic basket of the week
    picks = pick_recipes(candidates)
    # add picks to the corresponding recipe list
    picks.each do |recipe|
      RecipeListItem.create(recipe_id: recipe.id, recipe_list_id: list.id, position: 0, name: recipe.title, recommendation_id: recommendation.id)
    end
  end

  def self.create_gourmand_basket(recommendation)
    # set recipe list for classic basket
    list = RecipeList.find_by(name: "gourmand", recipe_list_type: "mama")
    # get list of proper recipes for classic basket
    all_recipes = @recipe_pool.select { |r| r.tag_list.any? { |tag| ["gourmand"].include?(tag) } }
    # exclude recipes from last week recommendation
    last_reco = Recommendation.where(recommendation_type: "gourmand").offset(1).last
    last_reco ? recipes = all_recipes - last_reco : recipes = all_recipes
    # select candidate recipes based on food checklist of the week
    candidates = get_checklist_candidates(recipes)
    # pick recipes for classic basket of the week
    picks = pick_recipes(candidates)
    # add picks to the corresponding recipe list
    picks.each do |recipe|
      RecipeListItem.create(recipe_id: recipe.id, recipe_list_id: list.id, position: 0, name: recipe.title, recommendation_id: recommendation.id)
    end
  end
end
