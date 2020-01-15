class CartsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:show]

  def new
    @cart = Cart.new
  end

  def create
    @cart = Cart.new(cart_params)
    @cart.user_id = current_user.id
    if @cart.save
      redirect_to cart_path(@cart)
    else
      redirect_to new_cart_path
    end
  end

  def index
    @carts = current_user.carts.where.not(merchant: nil)
    @cart = Cart.new
  end

  def show
    @cart = Cart.find(params[:id])
  end

  def search
    @cart = Cart.find(params[:id])
    @store = @cart.merchant.stores.first
    @search = Product.search(params[:query], fields: [:name, :brand], where:  {stores: @cart.merchant.name} )[0..49] if params[:query]
    render 'search.js.erb'
  end

  def share
    cart = Cart.find(params[:cart_id])
    email = params[:email]
    mail = CartMailer.share(cart, email)
    mail.deliver_now
    flash[:notice] = 'Le panier a été envoyé par email !'
    redirect_to cart_path(cart)
  end

  def special_share
    cart = Cart.find(params[:cart_id])
    email = params[:email]
    mail = CartMailer.special_share(cart, email)
    mail.deliver_now
    redirect_to cart_path(cart)
  end

  def destroy
    @cart = Cart.find(params[:id])
    @cart.destroy
    redirect_to carts_path
  end

  def add_to_cart
    @store_item = StoreItem.find(params[:store_item_id])
    @cart = Cart.find(params[:id])
    @cart_item = @cart.add_product(@store_item)
    render "add_to_cart.js.erb"
  end

  def fetch_price
    @cart = Cart.find(params[:cart_id])
    @price = @cart.get_total_price
    render 'fetch_price.js.erb'
  end

  private
  def cart_params
    params.require(:cart).permit(:cart_id, :user_id, :merchant_id)
  end
end
