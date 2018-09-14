class Cart < ApplicationRecord
  validates :user_id, uniqueness: true, presence: :true
  belongs_to :users, optional: true
  has_many :cart_items, dependent: :destroy
  has_many :recipes, :through => :cart_items, :source => :productable, :source_type => 'Recipe'
  has_many :foods, :through => :recipes

  def add_product(product)

    current_item = self.cart_items.find_by(productable_id: product[:productable_id], productable_type: product[:productable_type])

    if current_item
      current_item.quantity += 1
      current_item.save
    else
      CartItem.create(name: product[:name], productable_id: product[:productable_id], productable_type: product[:productable_type], quantity: 1, cart_id: self.id)
    end
  end

  def set_size(size)
    self.size = size
    self.save
  end
end
