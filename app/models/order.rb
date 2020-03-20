class Order < ApplicationRecord
  belongs_to :user
  belongs_to :cart, optional: true
  validates :user, presence: :true
  has_many :cart_items, dependent: :destroy
  has_many :recipes, :through => :cart_items, :source => :productable, :source_type => 'Recipe'
  has_many :foods, :through => :recipes

  ORDER_TYPE = ["grocery list", "drop-off"]

  def order_cart_items
    self.cart.cart_items.each do |cart_item|
      cart_item.order_id = self.id
      cart_item.cart_id = nil
      cart_item.save
    end
  end

  def add_product(product)
    CartItem.create(name: product[:name], productable_id: product[:productable_id], productable_type: product[:productable_type], quantity: 1, order_id: self.id)
  end

  def send_grocery_list
    grocery_list = self.foods.uniq.sort_by { |f| f.category_id }
  end
end
