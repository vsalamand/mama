class CartItem < ApplicationRecord
  validates :name, :quantity, :productable_id, :productable_type, presence: :true
  belongs_to :productable, :polymorphic => true
  belongs_to :cart, optional: true
  belongs_to :order, optional: true
  belongs_to :item, optional: true

end
