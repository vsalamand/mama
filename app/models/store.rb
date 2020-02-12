class Store < ApplicationRecord
  belongs_to :merchant
  has_many :store_items
  has_many :products, through: :store_items
  has_many :foods, through: :products

  STORE_TYPE = ["online", "physical"]


  def self.get_cheapest_store_price(items)
    cheapest_store = []
    Store.all.each do |store|
      data = store.get_cheapest_cart_price(items)
      min_price = sprintf("%.2f", data.pluck(:price).inject(0){|sum,x| sum + x })
      cheapest_store << [min_price, data.size, store]
    end

    # sort by cart price
    return cheapest_store.sort_by{|store| store.first.to_f}
  end

  def get_cheapest_cart_price(items)
    cheapest_cart_price = []
    items.each do |item|
      # for each item, get related products per store, sort by price, and return cheapest product
      cheapest_cart_price << StoreItem.get_results_sorted_by_price(item, self).first
    end

    # remove nil elements
    return cheapest_cart_price.compact!
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
