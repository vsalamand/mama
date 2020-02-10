class StoreCart < ApplicationRecord
  belongs_to :user
  belongs_to :store
  belongs_to :list, optional: true
  belongs_to :recipe, optional: true
  has_many :store_cart_items, dependent: :destroy

  def clean_store_cart
    if self.store_cart_items.any?
      self.store_cart_items.destroy_all
    end
  end

  def update_store_cart_items(items)
    self.clean_store_cart

    data = []

    items.each do |item|
      if item.food.present?
        # search products with item.food and merchant
        results = Product.search(item.name,
                                  fields: [:name, :brand],
                                  where:  {stores: self.store.name,
                                          food_id: item.food.id})

        # if results, sort results by price and get cheapest one
        if results.any?
          best_result = results.map{ |result| result.store_items.where(store: store).pluck(:price, :id, :is_available).reject {|x| x.first < 0.02 || x[2] == false } }.min
          store_item_match = StoreItem.find(best_result.first.second)

        # if no results, just get store items for given food and return cheapest one
        elsif StoreItem.get_cheapest_store_item(item.food, self.store).present?
          store_item_match = StoreItem.get_cheapest_store_item(item.food, self.store)
        end

      else
        store_item_match = Product.search(item.name,
                                fields: [:name, :brand],
                                where:  {stores: self.store.merchant.name}).first
        store_item_match = store_item_match.store_items.where(store_id: self.store.id).first unless store_item_match.nil?

      end

      data << StoreCartItem.create(store_cart_id: self.id,
                       store_item_id: store_item_match.id, item_id: item.id) unless store_item_match.nil?
    end

    self.save
    return data
  end

  def add_to_cart(cart)
    self.store_cart_items.reverse.each do |store_cart_item|
      cart.add_product(store_cart_item.store_item)
    end
  end

  # def get_store_cart_price
  #   # not WORKING because @store_cart return empty list of store_cart_items...
  #   self.store_cart_items.map{ |store_cart_item| store_cart_item.store_item.price}.inject(:+)
  # end

  def self.get_store_cart_price(store_cart_items)
    store_cart_items.map{ |store_cart_item| store_cart_item.store_item.price}.inject(:+).round(2)
  end
end
