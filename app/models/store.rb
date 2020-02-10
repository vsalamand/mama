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
      if item.food
        # store_item_match = StoreItem.get_cheapest_store_item(item.food, self)
        results = Product.search(item.name,
                                  fields: [:name, :brand],
                                  where:  {stores: self.name,
                                          food_id: item.food.id})

        # if results, sort results by price and get cheapest one
        if results.any?
          best_result = results.map{ |result| result.store_items.where(store: self).pluck(:price, :id, :is_available).reject {|x| x.first < 0.02 || x[2] == false } }.min
          store_item_match = StoreItem.find(best_result.first.second) if best_result.any?

        # if no results, just get store items for given food and return cheapest one
        elsif store_item_match.nil? || StoreItem.get_cheapest_store_item(item.food, self).present?
          store_item_match = StoreItem.get_cheapest_store_item(item.food, self)
        end

      else
        store_item_match = Product.search(item.name,
                            fields: [:name, :brand],
                            where:  {stores: self.merchant.name}).first
        store_item_match = store_item_match.store_items.where(store_id: self.id).first unless store_item_match.nil?
      end

      cheapest_cart_price << store_item_match unless store_item_match.nil? || cheapest_cart_price.include?(store_item_match)
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
