class Cart < ApplicationRecord
  validates :user_id, presence: :true
  belongs_to :user, optional: true
  belongs_to :merchant, optional: true
  has_many :cart_items, dependent: :destroy
  has_many :recipes, :through => :cart_items, :source => :productable, :source_type => 'Recipe'
  has_many :foods, :through => :recipes

  def add_product(store_item, item)
    if store_item.present?
      current_item = self.cart_items.find_by(name: store_item.name)

      if current_item
        # current_item.quantity += 1
        current_item.save
      else
        unless item.nil?
          CartItem.create(name: store_item.name, productable_id: store_item.id, productable_type: store_item.class.name, quantity: 1, cart: self, item_id: item.id)
        else
          CartItem.create(name: store_item.name, productable_id: store_item.id, productable_type: store_item.class.name, quantity: 1, cart: self)
        end
      end
    end
  end

  def clean_cart
    if self.cart_items.any?
      self.cart_items.destroy_all
    end
  end

  def update_cart(merchant_products)
    # clean current items
    # self.clean_cart
    #add new item
    merchant_products.each{ |product_data| self.add_product(product_data) if product_data["store_item"].present? }
  end

  def get_total_price
    prices_list = []
    self.cart_items.each do |cart_item|
      if cart_item.productable_id.present? && StoreItem.where(id: cart_item.productable_id).any?
        price = cart_item.quantity * StoreItem.find(cart_item.productable_id).price
        prices_list << price
      end
    end
    return sprintf("%.2f", prices_list.inject(0){|sum,x| sum + x })
  end

  def set_size(size)
    self.size = size
    self.save
  end

  # update cart for each available merchant
  def self.get_carts(list, user)
    Merchant.all.each do |merchant|
      merchant_products = StoreItem.get_cheap_store_items(list, merchant)
      cart = Cart.find_or_create_by(user_id: user.id, merchant_id: merchant.id)
      cart.update_cart(merchant_products)
    end
  end
end
