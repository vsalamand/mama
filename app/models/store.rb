class Store < ApplicationRecord
  belongs_to :merchant
  has_many :store_items
  has_many :products, through: :store_items
  has_many :foods, through: :products

  STORE_TYPE = ["online", "physical"]


  def get_recipe_price(recipe)
    recipe_cheapest_items_prices = []
    recipe.foods.each do |food|
      store_item = StoreItem.get_cheapest_store_item(food, self)
      recipe_cheapest_items_prices << store_item.price if store_item
    end
    return sprintf("%.2f", recipe_cheapest_items_prices.inject(0){|sum,x| sum + x })
  end

end
