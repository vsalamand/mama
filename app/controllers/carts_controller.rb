class CartsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:show]

  def show
    # trick to set cart object in order to get cart items because otherwise @cart is considered empty...
    # @cart = Cart.find_by(user_id: user)
    @cart = Cart.find(params[:id])
    # @list = List.find_by(user_id: current_user)
    @list = @cart.user.lists.first
    @unavailable = @list.list_items.no_items
  end

  def share
    cart = Cart.find(params[:cart_id])
    email = params[:email]
    CartMailer.share(cart, email)
    redirect_to cart_path(cart)
  end

  private
  def carts_params
    params.require(:cart).permit(:cart_id, :user_id)
  end
end
