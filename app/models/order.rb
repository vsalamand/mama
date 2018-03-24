class Order < ApplicationRecord
  belongs_to :user
  belongs_to :cart
  validates :order_type, :cart, :user, presence: :true
  has_many :cart_items

  ORDER_TYPE = ["Grocery list"]

  def order_cart_items
    self.cart.cart_items.each do |cart_item|
      cart_item.order_id = self.id
      cart_item.cart_id = nil
      cart_item.save
    end
  end
end
