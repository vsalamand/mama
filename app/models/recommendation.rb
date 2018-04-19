class Recommendation < ApplicationRecord
  has_many :recipe_list_items

  def self.create_express_menu(recommendation)
    # set recipe list for menu express
    menu_list = RecipeList.find_by(name: "rapide", recipe_list_type: "mama")
    # get all content matching the menu type
    inventory = Recipe.all.select { |r| r.tag_list.include?("rapide") && r.status == "published"}
    # get content from latest menu
    last_content = Recommendation.where(recommendation_type: "rapide").offset(1).last
    # remove content from latest menu to generate next menu
    last_content ? available = inventory - last_content.recipe_list_items : available = inventory
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
    inventory = Recipe.all.select { |r| r.tag_list.include?("snack") && r.status == "published"}
    # get content from latest menu
    last_content = Recommendation.where(recommendation_type: "snack").offset(1).last
    # remove content from latest menu to generate next menu
    last_content ? available = inventory - last_content.recipe_list_items : available = inventory
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
    inventory = Recipe.all.select { |r| r.tag_list.include?("léger") && r.status == "published"}
    # get content from latest menu
    last_content = Recommendation.where(recommendation_type: "léger").offset(1).last
    # remove content from latest menu to generate next menu
    last_content ? available = inventory - last_content.recipe_list_items : available = inventory
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
    inventory = Recipe.all.select { |r| r.tag_list.include?("tarte salée") && r.status == "published"}
    # get content from latest menu
    last_content = Recommendation.where(recommendation_type: "tarte salée").offset(1).last
    # remove content from latest menu to generate next menu
    last_content ? available = inventory - last_content.recipe_list_items : available = inventory
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
    inventory = Recipe.all.select { |r| r.tag_list.include?("gourmand") && r.status == "published"}
    # get content from latest menu
    last_content = Recommendation.where(recommendation_type: "gourmand").offset(1).last
    # remove content from latest menu to generate next menu
    last_content ? available = inventory - last_content.recipe_list_items : available = inventory
    # find recipes for next menu
    content = available.shuffle.take(5)
    # add recipes to the corresponding list
    content.each do |recipe|
      RecipeListItem.create(recipe_id: recipe.id, recipe_list_id: menu_list.id, position: 0, name: recipe.title, recommendation_id: recommendation.id)
    end
  end

end
