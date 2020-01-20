class StoreCartItemsController < ApplicationController
  def edit
  end

  def update
    @store_cart_item = StoreCartItem.find(params[:id])

    @list = List.find(params[:store_cart_item][:list_id]) if params[:store_cart_item][:list_id].present?
    @recipe = Recipe.find(params[:store_cart_item][:recipe_id]) if params[:store_cart_item][:recipe_id].present?

    @store_item = StoreItem.find(params[:store_cart_item][:store_item_id])
    @store_cart = StoreCart.find(params[:store_cart_id])

    @store_cart_item.update(store_item_id: @store_item.id, store_cart_id: @store_cart.id)
    render 'update.js.erb'
  end

  def destroy
    @store_cart_item = StoreCartItem.find(params[:id])
    @store_cart_item.destroy
    render "delete.js.erb"
  end

  def search
    @store_cart_item = StoreCartItem.find(params[:store_cart_item_id])
    @store_cart = StoreCart.find(params[:store_cart_id])
    @store = Store.find(params[:store_id])

    @search = Product.search(params[:query], fields: [:name, :brand], where:  {stores: @store.name} )[0..49] if params[:query]
    render 'search.js.erb'
  end

  def fetch_index
    @store_cart_item = StoreCartItem.find(params[:store_cart_item_id])
    render 'fetch_index.js.erb'
  end

  private

  def store_cart_item_params
    params.require(:store_cart_item).permit(:store_item_id, :store_cart_id, :list_id )
  end
end
