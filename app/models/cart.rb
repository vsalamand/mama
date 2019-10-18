class Cart < ApplicationRecord
  validates :user_id, uniqueness: true, presence: :true
  belongs_to :users, optional: true
  has_many :cart_items, dependent: :destroy
  has_many :recipes, :through => :cart_items, :source => :productable, :source_type => 'Recipe'
  has_many :foods, :through => :recipes

  def add_product(product_data)
    # product data is a hash with List item + item + store item (cheap)
    product = StoreItem.find(product_data["store_item"])
    current_item = self.cart_items.find_by(item_id: product_data["item"])

    if current_item
      # current_item.quantity += 1
      current_item.save
    else
      CartItem.create(name: product.name, productable_id: product.id, productable_type: product.class.name, quantity: 1, item_id: product_data["item"], cart: self)
    end
  end

  def clean_cart
    if self.cart_items.any?
      self.cart_items.destroy_all
    end
  end

  def update_cart(products_data)
    # clean current items
    # self.clean_cart
    #add new item
    products_data.each{ |product_data| self.add_product(product_data) if product_data["store_item"].present? }
  end

  def get_total_price
    prices_list = []
    self.cart_items.each do |item|
      price = item.quantity * StoreItem.find(item.productable_id).price
      prices_list << price
    end
    return sprintf("%.2f", prices_list.inject(0){|sum,x| sum + x })
  end

  def set_size(size)
    self.size = size
    self.save
  end
end
