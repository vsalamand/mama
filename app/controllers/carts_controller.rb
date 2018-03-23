class CartsController < ApplicationController
  before_action :set_cart

  private
  def set_cart
    @cart = Cart.find_or_create_by(user_id: params[:user])
  end

  def carts_params
    params.require(:cart).permit(:cart_id, :user_id)
  end
end
