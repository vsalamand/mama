class Order < ApplicationRecord
  belongs_to :user
  belongs_to :cart
  validates :order_type, :cart, :user, presence: :true
  has_many :cart_items, dependent: :destroy
  has_many :recipes, :through => :cart_items, :source => :productable, :source_type => 'Recipe'
  has_many :foods, :through => :recipes

  ORDER_TYPE = ["Grocery list", "Drop-off"]

  def order_cart_items
    self.cart.cart_items.each do |cart_item|
      cart_item.order_id = self.id
      cart_item.cart_id = nil
      cart_item.save
    end
  end

  def send_grocery_list
    grocery_list = self.foods.uniq.sort_by { |f| f.category_id }
  end
end
