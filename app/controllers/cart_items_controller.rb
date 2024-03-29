class CartItemsController < ApplicationController
  before_action :set_cart, only: [:create]

  def show
    @cart_item = CartItem.find_by(id: params[:id])
    @cart = Cart.find(params[:cart_id])
    @item = @cart_item.item
  end

  def edit
  end

  def update
    @cart_item = CartItem.find(params[:id])
    @cart = Cart.find(params[:cart_id])

    @cart_item.update(cart_item_params)
    render 'update.js.erb'
  end

  def destroy
    @cart_item = CartItem.find(params[:id])
    @cart_item.destroy
    render "delete.js.erb"
  end

  def search
    @cart_item = CartItem.find(params[:cart_item_id])
    @cart = Cart.find(params[:cart_id])
    @store_item = StoreItem.find(@cart_item.productable_id)
    @search = Product.search(params[:query], fields: [:name, :brand], where:  {stores: @cart.merchant.name} )[0..49] if params[:query]
    render 'search.js.erb'
  end

  private
  def set_cart_item
    @cart_item = CartItem.find(params[:productable_id])
  end

  def cart_item_params
    params.require(:cart_item).permit(:productable_id, :productable_type, :cart_id, :quantity, :name, :item_id)
  end
end
