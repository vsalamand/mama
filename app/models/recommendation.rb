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
  def get_weekly_food_checklist
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
      unless recipe.foods.find { |food| food.availability.exclude?(current_month)}
        @recipe_pool << recipe
      end
    end
  end

  # get list of recipes sort by nb of foods
  def self.get_checklist_candidates
    @candidates = []
    @recipe_pool.select do |r|
     if r.foods.any? { |f| @food_checklist.include? f } then @candidates << r end
    end
    @candidates = @candidates.sort_by{ |r| (@food_checklist - (@food_checklist - r.foods)).count }.reverse
  end

  # pick recipes in candidates list based on checklist constraints
  def self.pick_recipes
    picks = []
    checks = []
    # put the first candidate in the list of picks & tick the checklist
    picks << @candidates.first
    @candidates.first.foods.each { |f| checks << f if @food_checklist.include? f }
    # repeat the process until the pick list is full
    until picks.count == 10 || (@candidates - picks).count == 0
      new_pick = (@candidates - picks).find { |r| ((@food_checklist - checks.uniq) & r.foods).any? }
      if new_pick
        picks << new_pick
        new_pick.foods.each { |f| checks << f if @food_checklist.include? f }
      else
        picks << (@candidates - picks).first
      end
    end
  end


  def self.create_express_menu(recommendation)
    # set recipe list for menu express
    menu_list = RecipeList.find_by(name: "rapide", recipe_list_type: "mama")
    # get all content matching the menu type
    inventory = @recipe_pool.select { |r| r.tag_list.include?("rapide") && r.status == "published"}
    # get content from latest menu
    last_content = Recommendation.where(recommendation_type: "rapide").offset(1).last
    # remove content from latest menu to generate next menu
    last_content ? available = inventory - last_content.recipes : available = inventory
    # find recipes for next menu
    content = available.shuffle.take(5)
    # add recipes to the corresponding list
    content.each do |recipe|
      RecipeListItem.create(recipe_id: recipe.id, recipe_list_id: menu_list.id, position: 0, name: recipe.title, recommendation_id: recommendation.id)
    end
  end

  def self.create_snack_menu(recommendation)
    # set recipe list for menu express
    menu_list = RecipeList.find_by(name: "snack", recipe_list_type: "mama")
    # get all content matching the menu type
    inventory = @recipe_pool.select { |r| r.tag_list.include?("snack") && r.status == "published"}
    # get content from latest menu
    last_content = Recommendation.where(recommendation_type: "snack").offset(1).last
    # remove content from latest menu to generate next menu
    last_content ? available = inventory - last_content.recipes : available = inventory
    # find recipes for next menu
    content = available.shuffle.take(5)
    # add recipes to the corresponding list
    content.each do |recipe|
      RecipeListItem.create(recipe_id: recipe.id, recipe_list_id: menu_list.id, position: 0, name: recipe.title, recommendation_id: recommendation.id)
    end
  end

  def self.create_light_menu(recommendation)
    # set recipe list for menu express
    menu_list = RecipeList.find_by(name: "léger", recipe_list_type: "mama")
    # get all content matching the menu type
    inventory = @recipe_pool.select { |r| r.tag_list.include?("léger") && r.status == "published"}
    # get content from latest menu
    last_content = Recommendation.where(recommendation_type: "léger").offset(1).last
    # remove content from latest menu to generate next menu
    last_content ? available = inventory - last_content.recipes : available = inventory
    # find recipes for next menu
    content = available.shuffle.take(5)
    # add recipes to the corresponding list
    content.each do |recipe|
      RecipeListItem.create(recipe_id: recipe.id, recipe_list_id: menu_list.id, position: 0, name: recipe.title, recommendation_id: recommendation.id)
    end
  end

  def self.create_tart_menu(recommendation)
    # set recipe list for menu express
    menu_list = RecipeList.find_by(name: "tarte salée", recipe_list_type: "mama")
    # get all content matching the menu type
    inventory = @recipe_pool.select { |r| r.tag_list.include?("tarte salée") && r.status == "published"}
    # get content from latest menu
    last_content = Recommendation.where(recommendation_type: "tarte salée").offset(1).last
    # remove content from latest menu to generate next menu
    last_content ? available = inventory - last_content.recipes : available = inventory
    # find recipes for next menu
    content = available.shuffle.take(5)
    # add recipes to the corresponding list
    content.each do |recipe|
      RecipeListItem.create(recipe_id: recipe.id, recipe_list_id: menu_list.id, position: 0, name: recipe.title, recommendation_id: recommendation.id)
    end
  end

  def self.create_gourmet_menu(recommendation)
    # set recipe list for menu express
    menu_list = RecipeList.find_by(name: "gourmand", recipe_list_type: "mama")
    # get all content matching the menu type
    inventory = @recipe_pool.select { |r| r.tag_list.include?("gourmand") && r.status == "published"}
    # get content from latest menu
    last_content = Recommendation.where(recommendation_type: "gourmand").offset(1).last
    # remove content from latest menu to generate next menu
    last_content ? available = inventory - last_content.recipes : available = inventory
    # find recipes for next menu
    content = available.shuffle.take(5)
    # add recipes to the corresponding list
    content.each do |recipe|
      RecipeListItem.create(recipe_id: recipe.id, recipe_list_id: menu_list.id, position: 0, name: recipe.title, recommendation_id: recommendation.id)
    end
  end

end
