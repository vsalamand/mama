class FoodList < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :diet, optional: true

  validates :name, :food_list_type, presence: :true
  has_many :foods, through: :food_list_items
  has_many :food_list_items

  FOOD_LIST_TYPE = ["recommendation", "ban", "personal", "pool"]

  def self.update_banned_foods(diet)
    banned_foods = FoodList.find_by(diet_id: diet.id, food_list_type: "ban")

    # add food in foodlist unless already in
    if diet.banned_categories.any?
      diet.banned_categories.each do |banned_category|
        banned_category.category.foods.each { |food| FoodListItem.find_or_create_by(name: food.name, food_id: food.id, food_list_id: banned_foods.id) }
      end
    end
    if diet.banned_foods.any?
      diet.banned_foods.each do |banned_food|
        banned_food.food.subtree.each { |food| FoodListItem.find_or_create_by(name: food.name, food_id: food.id, food_list_id: banned_foods.id) }
      end
    end
  end


  def self.update_food_pools
    # find food that's not available in the given month
    available_date = Date.today.next_week.strftime("%m")
    available_food = Food.where("availability ~ ?", available_date)
    available_food_root = Food.roots.where("availability ~ ?", available_date).to_a
    unavailable_food = Food.all - available_food
    # MAIN SEASONAL FOODLIST
    seasonal_list = FoodList.find_or_create_by(name: "seasonal foods", food_list_type: "pool")
    seasonal_candidates = Food.where("availability ~ ?", available_date)
    FoodList.update_food(seasonal_list, unavailable_food, seasonal_candidates)

    # SEASONAL VEGGIES
    list = FoodList.find_or_create_by(name: "vegetables", food_list_type: "pool")
    candidates = (Category.find(14).foods.roots & available_food_root) - Category.find(14).foods.tagged_with("légumes bulbes")
    FoodList.update_food(list, unavailable_food, candidates)
    # SEASONAL LEAFY VEGGIES
    list = FoodList.find_or_create_by(name: "leafy vegetables", food_list_type: "pool")
    candidates = Category.find(14).foods.roots.tagged_with("légumes feuilles") & available_food_root
    FoodList.update_food(list, unavailable_food, candidates)
    # SEASONAL FLOWER VEGGIES
    list = FoodList.find_or_create_by(name: "flower vegetables", food_list_type: "pool")
    candidates = Category.find(14).foods.roots.tagged_with("légumes fleurs") & available_food_root
    FoodList.update_food(list, unavailable_food, candidates)
    # SEASONAL FRUIT VEGGIES
    list = FoodList.find_or_create_by(name: "fruit vegetables", food_list_type: "pool")
    candidates = Category.find(14).foods.roots.tagged_with("légumes fruits") & available_food_root
    FoodList.update_food(list, unavailable_food, candidates)
    # SEASONAL ROOT VEGGIES
    list = FoodList.find_or_create_by(name: "root vegetables", food_list_type: "pool")
    candidates = Category.find(14).foods.roots.tagged_with("légumes racines") & available_food_root
    FoodList.update_food(list, unavailable_food, candidates)
    # SEASONAL STALK VEGGIES
    list = FoodList.find_or_create_by(name: "stalk vegetables", food_list_type: "pool")
    candidates = Category.find(14).foods.roots.tagged_with("légumes tiges") & available_food_root
    FoodList.update_food(list, unavailable_food, candidates)
    # SEASONAL LEGUMES
    list = FoodList.find_or_create_by(name: "legumes", food_list_type: "pool")
    candidates = Category.find(22).foods.roots & available_food_root
    FoodList.update_food(list, unavailable_food, candidates)
    # SEASONAL GAINS & NUTS
    list = FoodList.find_or_create_by(name: "grains & nuts", food_list_type: "pool")
    candidates = Category.find(15).foods.roots & available_food_root
    FoodList.update_food(list, unavailable_food, candidates)
    # SEASONAL CEREALS
    list = FoodList.find_or_create_by(name: "cereals", food_list_type: "pool")
    candidates = (Category.find(20).foods.roots + Category.find(21).foods.roots) & available_food_root
    FoodList.update_food(list, unavailable_food, candidates)
    # SEASONAL STARCHY FOOD
    list = FoodList.find_or_create_by(name: "starchy foods", food_list_type: "pool")
    candidates = (Category.find(20).foods.roots + Category.find(21).foods.roots) & available_food_root
    candidates << Food.find(53)
    FoodList.update_food(list, unavailable_food, candidates)
    # SEASONAL MEAT
    list = FoodList.find_or_create_by(name: "meat", food_list_type: "pool")
    candidates = (Category.find(23).foods.roots + Category.find(27).foods.roots) & available_food_root
    FoodList.update_food(list, unavailable_food, candidates)
    # SEASONAL POULTRY
    list = FoodList.find_or_create_by(name: "poultry", food_list_type: "pool")
    candidates = Category.find(28).foods.roots & available_food_root
    FoodList.update_food(list, unavailable_food, candidates)
    # SEASONAL FATTY FISHES
    list = FoodList.find_or_create_by(name: "fatty fishes", food_list_type: "pool")
    candidates = Category.find(25).foods.roots & available_food_root
    FoodList.update_food(list, unavailable_food, candidates)
    # SEASONAL FISH & SEAFOOD
    list = FoodList.find_or_create_by(name: "fish & seafood", food_list_type: "pool")
    candidates = Category.find(26).foods.roots & available_food_root
    FoodList.update_food(list, unavailable_food, candidates)
    # SEASONAL CHEESES
    list = FoodList.find_or_create_by(name: "cheeses", food_list_type: "pool")
    candidates = Category.find(30).foods.roots & available_food_root
    FoodList.update_food(list, unavailable_food, candidates)
    # SEASONAL PROTEIN
    list = FoodList.find_or_create_by(name: "protein foods", food_list_type: "pool")
    candidates = (Category.find(22).foods.roots + Category.find(15).foods.roots + Category.find(23).foods.roots + Category.find(27).foods.roots + Category.find(28).foods.roots) & available_food_root
    candidates << Food.find(30)
    FoodList.update_food(list, unavailable_food, candidates)
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

  def self.get_foodlist(list)
    foodlist = []
    list.foods.each { |f| foodlist << f.name }
    return foodlist.join(", ")
  end
end
