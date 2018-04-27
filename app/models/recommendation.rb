class Recommendation < ApplicationRecord
  has_many :recipe_list_items
  has_many :recipes, through: :recipe_list_items


  #1 get checklist of foods items
  def get_food_checklist
    food_checklist = []
  end

  #2 get list of recipes sort by nb of foods
  def get_checklist_candidates(food_checklist)
    candidates = []
    @pool.select do |r|
     if r.foods.any? { |f| food_checklist.include? f } then candidates << r end
    end
    candidates.sort_by{ |r| (foods - (foods - r.foods)).count }
  end

  #3 select recipes based on constraints
  def pick_recipes(candidates, food_checklist)
    picks = []
    checks = []

    picks << candidates.first
    candidates.first.foods.each { |f| checks << f if food_checklist.include? f }

    until picks == 5 || (candidates - picks) == 0
      pick = (candidates - picks).find { |r| (food_checklist - checks.uniq).include? r)
      if pick
        picks << pick
        pick.foods.each { |f| checks << f if food_checklist.include? f }
      else
        picks << (candidates - picks).first
      end
    end
  end



  # exclude recipes when they contain food that's not available in the given month
  def self.update_recipe_pool
    @pool = []
    current_month = Date.today.strftime("%m")
    Recipe.all.select do |recipe|
      unless recipe.foods.find { |food| food.availability.exclude?(current_month)}
        @pool << recipe
      end
    end
  end

  def self.create_express_menu(recommendation)
    # set recipe list for menu express
    menu_list = RecipeList.find_by(name: "rapide", recipe_list_type: "mama")
    # get all content matching the menu type
    inventory = @pool.select { |r| r.tag_list.include?("rapide") && r.status == "published"}
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
    inventory = @pool.select { |r| r.tag_list.include?("snack") && r.status == "published"}
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
    inventory = @pool.select { |r| r.tag_list.include?("léger") && r.status == "published"}
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
    inventory = @pool.select { |r| r.tag_list.include?("tarte salée") && r.status == "published"}
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
    inventory = @pool.select { |r| r.tag_list.include?("gourmand") && r.status == "published"}
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
