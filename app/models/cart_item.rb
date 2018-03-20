class CartItem < ApplicationRecord
  belongs_to :productable, :polymorphic => true
  belongs_to :cart
end
