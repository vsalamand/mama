class Checklist < ApplicationRecord
  has_many :food_list_items, dependent: :destroy
  has_many :foods, through: :food_list_items
  belongs_to :diet, optional: true


  def self.get_checklist(foods)
    # Checklist.find_or_create_by(name: "Checklist")
    checklist = Hash.new
    checklist["seasonal vegetables"] = Checklist.seasonal_vegetables?(foods)
    checklist["cruciferous vegetables"] = Checklist.cruciferous_vegetables?(foods)
    checklist["leafy vegetables"] = Checklist.leafy_vegetables?(foods)
    checklist["legumes"] = Checklist.legumes?(foods)
    checklist["cereals"] = Checklist.cereals?(foods)
    checklist["oleaginous"] = Checklist.oleaginous?(foods)
    return checklist
  end

  def self.seasonal_vegetables?(foods)
    (foods & (FoodList.find_by(name: "#{Date.today.next_week.strftime("%m")} vegetables", food_list_type: "pool").foods - FoodList.find_by(name: "leafy vegetables", food_list_type: "pool").foods)).any? ? true : false
  end

  def self.cruciferous_vegetables?(foods)
    (foods & FoodList.find_by(name: "cruciferous vegetables", food_list_type: "pool").foods).any? ? true : false
  end

  def self.leafy_vegetables?(foods)
    (foods & FoodList.find_by(name: "leafy vegetables", food_list_type: "pool").foods).any? ? true : false
  end

  def self.legumes?(foods)
    (foods & FoodList.find_by(name: "legumes", food_list_type: "pool").foods).any? ? true : false
  end

  def self.cereals?(foods)
    (foods & FoodList.find_by(name: "cereals", food_list_type: "pool").foods).any? ? true : false
  end

  def self.oleaginous?(foods)
    (foods & FoodList.find_by(name: "oleaginous", food_list_type: "pool").foods).any? ? true : false
  end


  # def self.pick_foods(diet)
  #   # create a checklist of foods items to pick recipes
  #   checklist = []

  #   # add 1 food from each vegetable family + 2 kinds of cereals + 2 kinds of legumes
  #   checklist <<  FoodList.find_by(name: "leafy vegetables", food_list_type: "pool").foods.shuffle.take(1)
  #   checklist <<  FoodList.find_by(name: "flower vegetables", food_list_type: "pool").foods.shuffle.take(1)
  #   checklist <<  FoodList.find_by(name: "fruit vegetables", food_list_type: "pool").foods.shuffle.take(1)
  #   checklist <<  FoodList.find_by(name: "root vegetables", food_list_type: "pool").foods.shuffle.take(1)
  #   checklist <<  FoodList.find_by(name: "stalk vegetables", food_list_type: "pool").foods.shuffle.take(1)
  #   checklist <<  FoodList.find_by(name: "starchy foods", food_list_type: "pool").foods.shuffle.take(3)
  #   checklist <<  FoodList.find_by(name: "legumes", food_list_type: "pool").foods.shuffle.take(2)

  #   checklist = checklist.flatten.uniq
  #   checklist.each do |food|
  #     FoodListItem.create(name: food.name, food_id: food.id, checklist_id: diet.checklists.last.id)
  #   end
  # end

  # def self.get_food_children(checklist)
  #   # for each food, get the food children and verify category and availability
  #   food_list = []
  #   checklist.each do |food|
  #     food.subtree.where(category: food.category).where("availability ~ ?", Date.today.strftime("%m")).each { |item| food_list << item}
  #   end
  #   return food_list
  # end
end
