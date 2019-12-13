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
    @recipe = Recipe.find(params[:recipe_id])
  end

  private
  def stores_params
    params.require(:product).permit(:id, :name, :store_type, :merchant_id)
  end
end
