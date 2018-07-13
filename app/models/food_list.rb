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
end
