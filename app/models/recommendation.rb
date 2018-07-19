class Recommendation < ApplicationRecord
  has_many :recipe_list_items, dependent: :destroy
  has_many :recipes, through: :recipe_list_items

  # get list of recipes sort by nb of foods
  def self.get_candidates(diet, type, schedule)
    # list food and food children from checklist (ancestry gem)
    checklist = Checklist.find_by(diet_id: diet.id, schedule: schedule).foods
    food_list = Checklist.get_food_children(checklist)

    # get list of the diet recipes that correspond to the right type of bucket
    recipe_list = RecipeList.find_by(diet_id: diet.id, recipe_list_type: "pool").recipes.select{ |r| r.tag_list.any? { |tag| type.include?(tag) } }
    # exclude recipes from last week recommendation if any
    last_reco = Recommendation.find_by(diet_id: diet.id, recommendation_type: type)
    last_reco.present? ? eligible_recipes = recipe_list - last_reco.recipes : eligible_recipes = recipe_list

    # find recipes that include at least one of the food in the list
    candidates = []
    eligible_recipes.select do |recipe|
      if recipe.foods.any? { |food| food_list.include? food }
        then candidates << recipe
      end
    end
    return candidates = candidates.sort_by{ |r| (food_list - (food_list - r.foods)).count }.reverse
  end

  # pick recipes in candidates list based on checklist constraints
  def self.pick_candidates(candidates, diet)
    checklist = Checklist.find_by(diet_id: diet.id).foods
    food_list = Checklist.get_food_children(checklist)

    picks = []
    checks = []
    # Pick candidates with most foods in the checklist not checked already, then check the food, and continue until the pick list is full
    until picks.count == 10 || (candidates - picks).count == 0
      new_pick = (candidates - picks).find { |r| ((food_list - Checklist.get_food_children(checks).uniq) & r.foods).any? }
      if new_pick
        picks << new_pick
        (new_pick.foods & food_list).each { |food| checks << food.root}
      else
        picks << (candidates - picks).first
      end
    end
    return picks
  end

  def self.update_user_weekly_menu(user, schedule)
    # retrieve all the relevant information
    weekly_menu = RecipeList.find_by(user_id: user.id, recipe_list_type: "recommendation")
    # weekly_menu.diet = Diet.find(1) if weekly_menu.diet.nil?
    user_banned_recipes = RecipeList.find_by(user_id: user.id, recipe_list_type: "ban")
    user_history = RecipeList.find_by(user_id: user.id, recipe_list_type: "history")
    diet_recos = Recommendation.where(diet_id: user.diet_id, schedule: schedule)
    # get the list of recommended recipes for the user
    user_recos = []
    diet_recos.each { |reco| user_recos << reco.recipes }
    user_recos = user_recos.flatten
    user_recos = user_recos - user_banned_recipes.recipes unless user_banned_recipes.nil?
    # pass remaining items from previous week into history list
    weekly_menu.recipe_list_items.each do |recipe_item|
      recipe_item.recipe_list_id = user_history.id
      recipe_item.save
    end
    # add new recipe to the weekly list
    user_recos.each { |recipe| RecipeListItem.find_or_create_by(name: recipe.title, recipe_id: recipe.id, recipe_list_id: weekly_menu.id, position: 0)}
  end
end
