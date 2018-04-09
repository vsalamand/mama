class CartItemsController < ApplicationController
  before_action :set_cart, only: [:create, :destroy]
  before_action :set_cart_item, only: [:destroy]

  def self.create(product)
    @cart = Cart.find(product[:cart_id])
    @cart.add_product(product)
    @cart.save
  end

  def destroy
    @cart_item.destroy
  end

  private
  def set_cart_item
    @cart_item = CartItem.find(params[:productable_id])
  end

  def cart_item_params
    params.require(:cart_item).permit(:productable_id, :productable_type, :cart_id, :quantity, :name)
  end
end
