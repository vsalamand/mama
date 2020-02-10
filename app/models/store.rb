class Store < ApplicationRecord
  belongs_to :merchant
  has_many :store_items
  has_many :products, through: :store_items
  has_many :foods, through: :products

  STORE_TYPE = ["online", "physical"]


  # def get_cheapest_cart_price(foods)
  #   cheapest_cart_price = []
  #   foods.each do |food|
  #     store_item = StoreItem.get_cheapest_store_item(food, self)
  #     cheapest_cart_price << store_item.price if store_item
  #   end
  #   return [sprintf("%.2f", cheapest_cart_price.inject(0){|sum,x| sum + x }), cheapest_cart_price.size]
  # end

  def get_cheapest_cart_price(items)
    cheapest_cart_price = []

    items.each do |item|
      store_item_match = StoreItem.get_results_sorted_by_price(item, self).first

      cheapest_cart_price << store_item_match unless store_item_match.nil?
    end

    return [sprintf("%.2f", cheapest_cart_price.pluck(:price).inject(0){|sum,x| sum + x }), cheapest_cart_price.size]
  end

  def self.get_cheapest_store_price(items)
    cheapest_store = []
    Store.all.each do |store|
      cheapest_store << [store.get_cheapest_cart_price(items).first, store.get_cheapest_cart_price(items).second, store]
    end

    # sort by cart price
    return cheapest_store.sort_by{|store| store.first.to_f}
  end

  def get_main_shelter_list
    self.store_items.pluck(:shelters).uniq.map{ |array| array.first}.uniq
  end

  def get_sub_shelves(store_shelf)
    self.store_items.pluck(:shelters).uniq.select{ |shelves| shelves.include?(store_shelf)}.map{ |element| element[1..] }.uniq.split.flatten.uniq - Array(store_shelf)
  end

  def get_main_store_shelves(store_shelf)
    self.store_items.pluck(:shelters).uniq.select{ |shelves| shelves.include?(store_shelf)}.map{ |element| element.first}.uniq
  end

end
