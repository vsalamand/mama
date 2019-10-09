class CartsController < ApplicationController

  def show
    # trick to set cart object in order to get cart items because otherwise @cart is considered empty...
    # @cart = Cart.find_by(user_id: user)
    @cart = Cart.find(params[:id])
  end

  private
  def carts_params
    params.require(:cart).permit(:cart_id, :user_id)
  end
end
