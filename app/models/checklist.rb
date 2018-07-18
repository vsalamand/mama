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
    # MAIN SEASONAL FOODLIST
    seasonal_list = FoodList.find_or_create_by(name: "seasonal foods", food_list_type: "pool")
    seasonal_candidates = Food.where("availability ~ ?", available_date)
    Checklist.update_food(seasonal_list, unavailable_food, seasonal_candidates)

    # SEASONAL VEGGIES
    list = FoodList.find_or_create_by(name: "vegetables (seasonal)", food_list_type: "pool")
    candidates = (Category.find(14).foods.roots & available_food_root) - Category.find(14).foods.tagged_with("légumes bulbes")
    Checklist.update_food(list, unavailable_food, candidates)
    # SEASONAL LEAFY VEGGIES
    list = FoodList.find_or_create_by(name: "leafy vegetables (seasonal)", food_list_type: "pool")
    candidates = Category.find(14).foods.roots.tagged_with("légumes feuilles") & available_food_root
    Checklist.update_food(list, unavailable_food, candidates)
    # SEASONAL FLOWER VEGGIES
    list = FoodList.find_or_create_by(name: "flower vegetables (seasonal)", food_list_type: "pool")
    candidates = Category.find(14).foods.roots.tagged_with("légumes fleurs") & available_food_root
    Checklist.update_food(list, unavailable_food, candidates)
    # SEASONAL FRUIT VEGGIES
    list = FoodList.find_or_create_by(name: "fruit vegetables (seasonal)", food_list_type: "pool")
    candidates = Category.find(14).foods.roots.tagged_with("légumes fruits") & available_food_root
    Checklist.update_food(list, unavailable_food, candidates)
    # SEASONAL ROOT VEGGIES
    list = FoodList.find_or_create_by(name: "root vegetables (seasonal)", food_list_type: "pool")
    candidates = Category.find(14).foods.roots.tagged_with("légumes racines") & available_food_root
    Checklist.update_food(list, unavailable_food, candidates)
    # SEASONAL STALK VEGGIES
    list = FoodList.find_or_create_by(name: "stalk vegetables (seasonal)", food_list_type: "pool")
    candidates = Category.find(14).foods.roots.tagged_with("légumes tiges") & available_food_root
    Checklist.update_food(list, unavailable_food, candidates)
    # SEASONAL LEGUMES
    list = FoodList.find_or_create_by(name: "legumes (seasonal)", food_list_type: "pool")
    candidates = Category.find(22).foods.roots & available_food_root
    Checklist.update_food(list, unavailable_food, candidates)
    # SEASONAL GAINS & NUTS
    list = FoodList.find_or_create_by(name: "grains & nuts (seasonal)", food_list_type: "pool")
    candidates = Category.find(15).foods.roots & available_food_root
    Checklist.update_food(list, unavailable_food, candidates)
    # SEASONAL CEREALS
    list = FoodList.find_or_create_by(name: "cereals (seasonal)", food_list_type: "pool")
    candidates = (Category.find(20).foods.roots + Category.find(21).foods.roots) & available_food_root
    Checklist.update_food(list, unavailable_food, candidates)
    # SEASONAL STARCHY FOOD
    list = FoodList.find_or_create_by(name: "starchy foods (seasonal)", food_list_type: "pool")
    candidates = (Category.find(14).foods.roots.tagged_with("légumes tubercules") + Category.find(22).foods.roots + Category.find(20).foods.roots + Category.find(21).foods.roots) & available_food_root
    Checklist.update_food(list, unavailable_food, candidates)
    # SEASONAL MEAT
    list = FoodList.find_or_create_by(name: "meat (seasonal)", food_list_type: "pool")
    candidates = (Category.find(23).foods.roots + Category.find(27).foods.roots) & available_food_root
    Checklist.update_food(list, unavailable_food, candidates)
    # SEASONAL POULTRY
    list = FoodList.find_or_create_by(name: "poultry (seasonal)", food_list_type: "pool")
    candidates = Category.find(28).foods.roots & available_food_root
    Checklist.update_food(list, unavailable_food, candidates)
    # SEASONAL FATTY FISHES
    list = FoodList.find_or_create_by(name: "fatty fishes (seasonal)", food_list_type: "pool")
    candidates = Category.find(25).foods.roots & available_food_root
    Checklist.update_food(list, unavailable_food, candidates)
    # SEASONAL FISH & SEAFOOD
    list = FoodList.find_or_create_by(name: "fish & seafood (seasonal)", food_list_type: "pool")
    candidates = Category.find(26).foods.roots & available_food_root
    Checklist.update_food(list, unavailable_food, candidates)
    # SEASONAL CHEESES
    list = FoodList.find_or_create_by(name: "cheeses (seasonal)", food_list_type: "pool")
    candidates = Category.find(30).foods.roots & available_food_root
    Checklist.update_food(list, unavailable_food, candidates)
    # SEASONAL PROTEIN
    list = FoodList.find_or_create_by(name: "protein foods (seasonal)", food_list_type: "pool")
    candidates = (Food.find(30) + Category.find(22).foods.roots + Category.find(15).foods.roots + Category.find(23).foods.roots + Category.find(27).foods.roots + Category.find(28).foods.roots) & available_food_root
    Checklist.update_food(list, unavailable_food, candidates)
  end

  def self.update_food(list, unavailable_food, candidates)
    #!!! delete items in the list when they are no longer seasonal
    list.food_list_items.each do |food_item|
      food_item.destroy if unavailable_food.include?(food_item.food)
    end
    # then add new seasonal candidates in the list
    candidates.each do |food|
      FoodListItem.find_or_create_by(name: food.name, food_id: food.id, food_list_id: list.id)
    end
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
