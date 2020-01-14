class StoreCartsController < ApplicationController
  def show
    @store_cart = StoreCart.find(params[:id])
    @store = Store.find(params[:store_id])
    @recipe = Recipe.find(params[:recipe_id]) if params[:recipe_id]
    if params[:list_id]
      @list = List.find(params[:list_id])
      @items = @list.list_items.not_completed.map{ |list_item| list_item.items.first }
      @list_foods = @list.list_items.not_completed.map{ |item| item.food }.flatten
      @store_cart_items = @store_cart.update_store_cart_items(@items).reverse
    end
    if params[:recipe_id]
      @recipe = Recipe.find(params[:recipe_id])
      @items = @recipe.items
      @store_cart_items = @store_cart.update_store_cart_items(@items).reverse
    end
    @carts = current_user.carts.where(merchant: @store.merchant).order(:created_at).reverse
    @cart = Cart.new
    # create new list of store cart items
  end

  def add_to_cart
    @store_cart = StoreCart.find(params[:id])

    params[:cart] ? @cart = Cart.find(params[:cart]) : @cart = Cart.create(user: current_user, merchant: @store_cart.store.merchant)

    @store_cart.add_to_cart(@cart)
    redirect_to cart_path(@cart)
  end

  def fetch_price
    @store_cart = StoreCart.find(params[:store_cart_id])
    @store_cart_items = @store_cart.store_cart_items
    @price = StoreCart.get_store_cart_price(@store_cart_items)
    @carts = current_user.carts.where(merchant: @store_cart.store.merchant).order(:created_at).reverse
    render 'fetch_price.js.erb'
  end


  private
  def store_cart_params
    params.require(:store_cart).permit(:id, :store, :user, :list, :recipe)
  end
end
