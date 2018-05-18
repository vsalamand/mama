class Checklist < ApplicationRecord
  has_many :food_list_items
  has_many :foods, through: :food_list_items

  # create a checklist of foods items
  def self.update_food_pools
    # exclude food that's not available in the given month
    available_food = []
    available_date = Date.today.next_week.strftime("%m")
    Food.roots.select do |food|
      available_food << food if food.availability.include?(available_date)
    end
    # list foods by category
    food_pools = {}
    food_pools["vegetables"] = Category.find(14).foods.roots & available_food
    food_pools["oelaginous"] = Category.find(15).foods.roots & available_food
    food_pools["starches"] = (Category.find(20).foods.roots + Category.find(21).foods.roots) & available_food
    food_pools["legumes"] = Category.find(22).foods.roots & available_food
    food_pools["delicatessen"] = Category.find(23).foods.roots & available_food
    food_pools["fatty_fish"] = Category.find(25).foods.roots & available_food
    food_pools["other_fish"] = Category.find(26).foods.roots & available_food
    food_pools["meat"] = Category.find(27).foods.roots & available_food
    food_pools["poultry"] = Category.find(28).foods.roots & available_food
    food_pools["eggs"] = Food.find(30)
    food_pools["pasta"] = Food.find(3)
    food_pools["rice"] = Food.find(21)
    return food_pools
  end

  def create_balanced_checklist(checklist, food_pools)
    # set recipe list for classic basket
    list = FoodList.find_by(name: "équilibré", food_list_type: "mama")
    # build checklist of food
    balanced_checklist = []
    balanced_checklist << food_pools["vegetables"].shuffle.take(4)
    balanced_checklist << food_pools["legumes"].shuffle.take(2)
    balanced_checklist << food_pools["poultry"].shuffle.take(1)
    balanced_checklist << food_pools["meat"].shuffle.take(1)
    balanced_checklist << food_pools["fatty_fish"].shuffle.take(1)
    balanced_checklist << food_pools["eggs"]
    balanced_checklist << food_pools["pasta"]
    balanced_checklist << food_pools["rice"]
    return balanced_checklist = balanced_checklist.flatten
    balanced_checklist.each do |food|
      FoodListItem.create(name: food.name, food_id: food.id, food_list_id: list, checklist_id: checklist.id)
    end
  end

end
