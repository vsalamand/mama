class CartItemsController < ApplicationController
  before_action :set_cart, only: [:create, :destroy]
  before_action :set_cart_item, only: [:destroy]

  def self.create(product)
    if product[:cart_id].present?
      @cart = Cart.find(product[:cart_id])
      @cart.add_product(product)
      @cart.save
    elsif product[:order_id].present?
      @order = Order.find(product[:order_id])
      @order.add_product(product)
      @order.save
    end
  end

  def show
    @cart_item = CartItem.find_by(productable_id: params[:id])
    @cart = Cart.find(params[:cart_id])
    @store_item = StoreItem.find(@cart_item.productable_id)
    @product = @store_item.product
    @food = @store_item.food
  end

  def edit
  end

  def update
    @cart_item = CartItem.find(params[:id])
    @cart_item.update(cart_item_params)
    @cart = Cart.find(params[:cart_id])
    redirect_to cart_path(@cart)
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
