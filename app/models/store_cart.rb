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
    results = []
    items.each do |item|
      if item.food.present? && StoreItem.get_cheapest_store_item(item.food, self.store).present?
        store_item_match = StoreItem.get_cheapest_store_item(item.food, self.store)
      else
        store_item_match = Product.search(item.name,
          fields: [:name, :brand],
          where:  {stores: self.store.merchant.name} )[0].store_items.where(store_id: self.store.id).first
      end
      results << StoreCartItem.create(store_cart_id: self.id,
          store_item_id: store_item_match.id)
    end
    self.save
    return results
  end

  def add_to_cart(cart)
    self.store_cart_items.each do |store_cart_item|
      cart.add_product(store_cart_item.store_item)
    end
  end

  # def get_store_cart_price
  #   # not WORKING because @store_cart return empty list of store_cart_items...
  #   self.store_cart_items.map{ |store_cart_item| store_cart_item.store_item.price}.inject(:+)
  # end

  def self.get_store_cart_price(store_cart_items)
    store_cart_items.map{ |store_cart_item| store_cart_item.store_item.price}.inject(:+)
  end
end
