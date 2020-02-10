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

      store_item_match = StoreItem.get_results_sorted_by_price(item, self.store).first

      data << StoreCartItem.create(store_cart_id: self.id,
                       store_item_id: store_item_match.id, item_id: item.id) unless store_item_match.nil?
    end

    self.save
    return data
  end

  def add_to_cart(cart)
    self.store_cart_items.each do |store_cart_item|
      cart.add_product(store_cart_item.store_item, store_cart_item.item)
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
