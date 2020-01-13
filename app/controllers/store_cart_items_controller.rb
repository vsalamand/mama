class StoreCartItemsController < ApplicationController
  def edit
  end

  def update
    @store_cart_item = StoreCartItem.find(params[:id])
    @list = List.find(params[:store_cart_item][:list_id])
    @store_item = StoreItem.find(params[:store_cart_item][:store_item_id])
    @store_cart = StoreCart.find(params[:store_cart_id])

    @store_cart_item.update(store_item_id: @store_item.id, store_cart_id: @store_cart.id)
    render 'update.js.erb'
  end

  private

  def store_cart_item_params
    params.require(:store_cart_item).permit(:store_item_id, :store_cart_id, :list_id )
  end
end
