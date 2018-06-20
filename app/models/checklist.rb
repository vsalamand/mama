class Checklist < ApplicationRecord
  has_many :food_list_items, dependent: :destroy
  has_many :foods, through: :food_list_items

  # create a checklist of foods items
  def self.update_food_pools
    # find food that's not available in the given month
    available_date = Date.today.next_week.strftime("%m")
    available_food = Food.where("availability ~ ?", available_date)
    available_food_root = Food.roots.where("availability ~ ?", available_date).to_a
    unavailable_food = Food.all - available_food

    # Update main seasonal foods list
    seasonal_foods = FoodList.find_or_create_by(name: "seasonal foods", food_list_type: "pool")
    #!!! delete items in the list when they are no longer seasonal
    seasonal_foods.food_list_items.each do |food_item|
      food_item.destroy if unavailable_food.include?(food_item.food)
    end
    # then add new seasonal items in the list
    Food.where("availability ~ ?", available_date).each do |food|
      FoodListItem.find_or_create_by(name: food.name, food_id: food.id, food_list_id: seasonal_foods.id)
    end

    # list foods by category !!! => to refactor into food lists
    food_pools = {}
    food_pools["vegetables"] = Category.find(14).foods.roots & available_food_root if Category.exists?(14)
    food_pools["oelaginous"] = Category.find(15).foods.roots & available_food_root if Category.exists?(15)
    food_pools["starches"] = (Category.find(20).foods.roots + Category.find(21).foods.roots) & available_food_root if Category.exists?(20)
    food_pools["legumes"] = Category.find(22).foods.roots & available_food_root if Category.exists?(22)
    food_pools["delicatessen"] = Category.find(23).foods.roots & available_food_root if Category.exists?(23)
    food_pools["fatty_fish"] = Category.find(25).foods.roots & available_food_root if Category.exists?(25)
    food_pools["other_fish"] = Category.find(26).foods.roots & available_food_root if Category.exists?(26)
    food_pools["meat"] = Category.find(27).foods.roots & available_food_root if Category.exists?(27)
    food_pools["poultry"] = Category.find(28).foods.roots & available_food_root if Category.exists?(28)
    food_pools["eggs"] = Food.find(30) if Food.exists?(30)
    food_pools["pasta"] = Food.find(3) if Food.exists?(3)
    food_pools["rice"] = Food.find(21) if Food.exists?(21)
    return food_pools
  end

  def self.pick_foods(diet, food_pools)
    # # set food list for diet checklist
    # list = FoodList.find_or_create_by(name: diet.name, diet_id: diet.id, food_list_type: "recommendation")
    # list.food_list_items.each do |item|
    #   item.food_list_id == nil
    #   item.save
    # end
    # add food to checklist
    checklist = []
    checklist << food_pools["vegetables"].shuffle.take(4) if food_pools.has_key?("vegetables")
    checklist << food_pools["legumes"].shuffle.take(2) if food_pools.has_key?("legumes")
    checklist << food_pools["pasta"] if food_pools.has_key?("pasta")
    checklist << food_pools["rice"] if food_pools.has_key?("rice")
    checklist << food_pools["meat"].shuffle.take(1) if food_pools.has_key?("meat")
    checklist << food_pools["fatty_fish"].shuffle.take(1) if food_pools.has_key?("fatty_fish")
    checklist << food_pools["poultry"].shuffle.take(1) if food_pools.has_key?("poultry")
    checklist << food_pools["eggs"] if food_pools.has_key?("eggs")
    # # for rake tests, add tomato
    # checklist << Food.find(1893)
    checklist = checklist.flatten
    checklist.each do |food|
      FoodListItem.create(name: food.name, food_id: food.id, checklist_id: diet.checklists.last.id)
    end
  end

end
