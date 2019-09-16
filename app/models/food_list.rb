class FoodList < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :diet, optional: true

  validates :name, :food_list_type, presence: :true
  has_many :foods, through: :food_list_items
  has_many :food_list_items, dependent: :destroy, inverse_of: :food_list

  accepts_nested_attributes_for :food_list_items, allow_destroy: true


  FOOD_LIST_TYPE = ["grocery_list", "recommendation", "ban", "personal", "pool"]

  # get list of similar foods from smartmama
  def get_similar_food
    if self.foods.any?
      begin
        items = []
        self.foods.map {|x| x.name}.each { |food| items << "item=#{food}"}
        url = URI.parse(URI::encode("https://smartmama.herokuapp.com/api/v1/predict?#{items.join("&")}"))
        data = JSON.parse(open(url).read)
        result = data.map {|x| x.values[0]}
        suggested_foods = []
        result.each { |food| suggested_foods << Food.search(food, fields: [{name: :exact}], misspellings: {edit_distance: 1}).first}
        return suggested_foods
      rescue
        return nil
      end
    else
      return nil
    end
  end

  # get list of vegetables & fruits of the month
  def get_seasonal_produce
    return Food.where(category: 14).where("availability ~ ?", "#{Date.today.strftime('%m')}") - Category.find(14).foods.tagged_with("légumes bulbes")
  end

  # send a short list of seasonal foods
  def self.get_foodlist(foods)

    foodlist = []
    # foods.sort_by { |f| f.recipes.where(status: "published").count }.reverse.each { |f| foodlist << f.name if f.recipes.where(status: "published").count > 0}
    foods.uniq.sort_by { |f| f.category_id }.map { |food| foodlist << food.name if food.recipes.where(status: "published").count > 0 }
    return foodlist.join(", ")
  end

  def self.update_food_pools
    # find food that's not available in the given month
    # available_date = Date.today.next_week.strftime("%m")
    # available_food = Food.where("availability ~ ?", available_date)
    # available_food_root = Food.roots.where("availability ~ ?", available_date).to_a
    # unavailable_food = Food.all - available_food
    # # MAIN SEASONAL FOODLIST
    # seasonal_list = FoodList.find_or_create_by(name: "seasonal foods", food_list_type: "pool")
    # seasonal_candidates = Food.where("availability ~ ?", available_date)
    # FoodList.update_food(seasonal_list, unavailable_food, seasonal_candidates)

    #EX to get ROOTS food => Category.find(14).foods.roots.tagged_with("légumes feuilles") & available_food_root

    #  VEGETABLES
    foods = Category.find(14).foods - Category.find(14).foods.tagged_with("légumes bulbes")
    FoodList.find_or_create_by(name: "vegetables", food_list_type: "pool").update_food(foods)

    # JAN VEGETABLES
    foods = Food.where(category: 14).where("availability ~ ?", "01") - Category.find(14).foods.tagged_with("légumes bulbes")
    FoodList.find_or_create_by(name: "01 vegetables", food_list_type: "pool").update_food(foods)
    # FEV VEGETABLES
    foods = Food.where(category: 14).where("availability ~ ?", "02") - Category.find(14).foods.tagged_with("légumes bulbes")
    FoodList.find_or_create_by(name: "02 vegetables", food_list_type: "pool").update_food(foods)
    # MAR VEGETABLES
    foods = Food.where(category: 14).where("availability ~ ?", "03") - Category.find(14).foods.tagged_with("légumes bulbes")
    FoodList.find_or_create_by(name: "03 vegetables", food_list_type: "pool").update_food(foods)
    # APR VEGETABLES
    foods = Food.where(category: 14).where("availability ~ ?", "04") - Category.find(14).foods.tagged_with("légumes bulbes")
    FoodList.find_or_create_by(name: "04 vegetables", food_list_type: "pool").update_food(foods)
    # MAY VEGETABLES
    foods = Food.where(category: 14).where("availability ~ ?", "05") - Category.find(14).foods.tagged_with("légumes bulbes")
    FoodList.find_or_create_by(name: "05 vegetables", food_list_type: "pool").update_food(foods)
    # JUN VEGETABLES
    foods = Food.where(category: 14).where("availability ~ ?", "06") - Category.find(14).foods.tagged_with("légumes bulbes")
    FoodList.find_or_create_by(name: "06 vegetables", food_list_type: "pool").update_food(foods)
    # JUL VEGETABLES
    foods = Food.where(category: 14).where("availability ~ ?", "07") - Category.find(14).foods.tagged_with("légumes bulbes")
    FoodList.find_or_create_by(name: "07 vegetables", food_list_type: "pool").update_food(foods)
    # AUG VEGETABLES
    foods = Food.where(category: 14).where("availability ~ ?", "08") - Category.find(14).foods.tagged_with("légumes bulbes")
    FoodList.find_or_create_by(name: "08 vegetables", food_list_type: "pool").update_food(foods)
    # SEP VEGETABLES
    foods = Food.where(category: 14).where("availability ~ ?", "09") - Category.find(14).foods.tagged_with("légumes bulbes")
    FoodList.find_or_create_by(name: "09 vegetables", food_list_type: "pool").update_food(foods)
    # OCT VEGETABLES
    foods = Food.where(category: 14).where("availability ~ ?", "10") - Category.find(14).foods.tagged_with("légumes bulbes")
    FoodList.find_or_create_by(name: "10 vegetables", food_list_type: "pool").update_food(foods)
    # NOV VEGETABLES
    foods = Food.where(category: 14).where("availability ~ ?", "11") - Category.find(14).foods.tagged_with("légumes bulbes")
    FoodList.find_or_create_by(name: "11 vegetables", food_list_type: "pool").update_food(foods)
    # DEC VEGETABLES
    foods = Food.where(category: 14).where("availability ~ ?", "12") - Category.find(14).foods.tagged_with("légumes bulbes")
    FoodList.find_or_create_by(name: "12 vegetables", food_list_type: "pool").update_food(foods)
    # YEARLY VEGETABLES
    foods = Food.where(category: 14).where(availability: "01, 02, 03, 04, 05, 06, 07, 08, 09, 10, 11, 12") - Category.find(14).foods.tagged_with("légumes bulbes")
    FoodList.find_or_create_by(name: "Yearly vegetables", food_list_type: "pool").update_food(foods)


    # LEAFY VEGGIES
    foods = Category.find(14).foods.tagged_with("légumes feuilles")
    FoodList.find_or_create_by(name: "leafy vegetables", food_list_type: "pool").update_food(foods)
    # FLOWER VEGGIES
    foods =Category.find(14).foods.tagged_with("légumes fleurs")
    FoodList.find_or_create_by(name: "flower vegetables", food_list_type: "pool").update_food(foods)
    # FRUIT VEGGIES
    foods = Category.find(14).foods.tagged_with("légumes fruits")
    FoodList.find_or_create_by(name: "fruit vegetables", food_list_type: "pool").update_food(foods)
    # ROOT VEGGIES
    foods = Category.find(14).foods.tagged_with("légumes racines")
    FoodList.find_or_create_by(name: "root vegetables", food_list_type: "pool").update_food(foods)
    # STALK VEGGIES
    foods = Category.find(14).foods.tagged_with("légumes tiges")
    FoodList.find_or_create_by(name: "stalk vegetables", food_list_type: "pool").update_food(foods)
    # BULB VEGGIES
    foods = Category.find(14).foods.tagged_with("légumes bulbes")
    FoodList.find_or_create_by(name: "bulb vegetables", food_list_type: "pool").update_food(foods)
    # CRUCIFEROUS VEGGIES
    foods = Category.find(14).foods.tagged_with("légumes crucifères")
    FoodList.find_or_create_by(name: "cruciferous vegetables", food_list_type: "pool").update_food(foods)

    # LEGUMES
    foods = Category.find(22).foods
    FoodList.find_or_create_by(name: "legumes", food_list_type: "pool").update_food(foods)
    # OLEAGINOUS
    foods = Category.find(15).foods
    FoodList.find_or_create_by(name: "oleaginous", food_list_type: "pool").update_food(foods)

    # CEREALS
    foods = (Category.find(20).foods + Category.find(21).foods)
    FoodList.find_or_create_by(name: "cereals", food_list_type: "pool").update_food(foods)
    # STARCHY FOOD
    foods = (Category.find(20).foods + Category.find(21).foods) << Food.find(53)
    FoodList.find_or_create_by(name: "starchy foods", food_list_type: "pool").update_food(foods)

    # MEAT
    foods = (Category.find(23).foods + Category.find(27).foods)
    FoodList.find_or_create_by(name: "meat", food_list_type: "pool").update_food(foods)
    # POULTRY
    foods = Category.find(28).foods
    FoodList.find_or_create_by(name: "poultry", food_list_type: "pool").update_food(foods)

    # FATTY FISHES
    foods = Category.find(25).foods
    FoodList.find_or_create_by(name: "fatty fishes", food_list_type: "pool").update_food(foods)
    # FISH & SEAFOOD
    foods = Category.find(26).foods
    FoodList.find_or_create_by(name: "fish & seafood", food_list_type: "pool").update_food(foods)

    # CHEESES
    foods = Category.find(30).foods
    FoodList.find_or_create_by(name: "cheeses", food_list_type: "pool").update_food(foods)

    # PROTEIN
    foods = (Category.find(22).foods + Category.find(15).foods + Category.find(23).foods + Category.find(27).foods + Category.find(28).foods ) << Food.find(30)
    FoodList.find_or_create_by(name: "protein foods", food_list_type: "pool").update_food(foods)
  end

  def update_food(foods)
    #!!! delete items in the list that are no longer here
    kill_list = self.foods - foods
    self.food_list_items.each do |food_item|
      food_item.destroy if kill_list.include?(food_item.food)
    end
    # then add new seasonal candidates in the list
    foods.each do |food|
      FoodListItem.find_or_create_by(name: food.name, food_id: food.id, food_list_id: self.id)
    end
  end

  # def self.update_banned_foods(diet)
  #   banned_foods = FoodList.find_by(diet_id: diet.id, food_list_type: "ban")

  #   # add food in foodlist unless already in
  #   if diet.banned_categories.any?
  #     diet.banned_categories.each do |banned_category|
  #       banned_category.category.foods.each { |food| FoodListItem.find_or_create_by(name: food.name, food_id: food.id, food_list_id: banned_foods.id) }
  #     end
  #   end
  #   if diet.banned_foods.any?
  #     diet.banned_foods.each do |banned_food|
  #       banned_food.food.subtree.each { |food| FoodListItem.find_or_create_by(name: food.name, food_id: food.id, food_list_id: banned_foods.id) }
  #     end
  #   end
  # end
end
