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
        results << StoreCartItem.create(store_cart_id: self.id,
          store_item_id: StoreItem.get_cheapest_store_item(item.food, self.store).id)
      end
    end
    return results
  end

  def add_to_cart(cart)
    self.store_cart_items.each do |store_cart_item|
      cart.add_product(store_cart_item.store_item)
    end
  end
end
