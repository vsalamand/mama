class StoreCartsController < ApplicationController
  def show
    @store_cart = StoreCart.find(params[:id])
    @store_cart_items = @store_cart.store_cart_items
    @list = @store_cart.list
  end

  def add_to_cart
    @store_cart = StoreCart.find(params[:id])

    # params[:cart] ? @cart = Cart.find(params[:cart]) : @cart = Cart.create(user: current_user, merchant: @store_cart.store.merchant)
    @cart = Cart.find_or_create_by(user_id: current_user.id, merchant_id: @store_cart.store.merchant.id)

    @store_cart.add_to_cart(@cart)

    redirect_to cart_path(@cart)
  end

  def index
    @list = List.find(params[:list_id])
    # @store_carts = @list.store_carts
  end

  def fetch_price
    @list = List.find(params[:list_id])
    @store_carts = @list.store_carts

    render 'fetch_price.js.erb'
  end



  private
  def store_cart_params
    params.require(:store_cart).permit(:id, :store, :user, :list, :recipe)
  end
end
