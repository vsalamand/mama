class StoresController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :show, :catalog, :cart ]

  def show
    @store = Store.find(params[:id])
    @shelves = @store.get_main_shelter_list
  end

  def index
    @stores = Store.all
  end

  def catalog
    @store = Store.find(params[:store_id])
    if params[:food_id]
      @food = Food.find(params[:food_id])
      @store_items = @food.store_items.where(store: @store)
    elsif params[:store_shelf]
      @store_shelf = params[:store_shelf]
      @shelves = @store.get_sub_shelves(@store_shelf)
      @main_store_shelves = @store.get_main_store_shelves(@store_shelf)
    elsif params[:store_item]
      @store_item = StoreItem.find(params[:store_item])
    end
  end

  def cart
    @store = Store.find(params[:store_id])
    # @recipe = Recipe.find(params[:recipe_id]) if params[:recipe_id]
    if params[:list_id]
      @list = List.find(params[:list_id])
      @store_cart = StoreCart.find_or_create_by(user: current_user, store: @store, list: @list)
      redirect_to store_store_cart_path(@store, @store_cart, :list_id => @list.id)
    end
    if params[:recipe_id]
      @recipe = Recipe.find(params[:recipe_id])
      @store_cart = StoreCart.find_or_create_by(user: current_user, store: @store, recipe: @recipe)
      redirect_to store_store_cart_path(@store, @store_cart, :recipe_id => @recipe.id)
    end
  end

  # def add_to_cart
  #   @store_item = StoreItem.find(params[:store_item_id])
  #   @cart = Cart.find(params[:cart])
  #   @cart_item = @cart.add_product(@store_item)
  #   render 'add_to_cart.js.erb'
  # end

  private
  def stores_params
    params.require(:product).permit(:id, :name, :store_type, :merchant_id)
  end
end
