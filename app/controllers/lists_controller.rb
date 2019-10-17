class ListsController < ApplicationController
  before_action :set_list, only: [ :show ]
  skip_before_action :authenticate_user!, only: [:show]
  before_action :authenticate_admin!, only: [:index, :new, :create]

  def show
    @list = List.find(params[:id])
    @list_item = ListItem.new
    @list_items = @list.list_items.not_deleted
    @recipes = RecipeList.where(recipe_list_type: "curated").last.recipes
  end

  def fetch_recipes
    @list = List.find(params[:list_id])
    @list_item = ListItem.new
    @recipes = RecipeList.where(recipe_list_type: "curated").last.recipes
    render 'fetch_recipes.js.erb'
  end

  def get_cart
    @list = List.find(params[:list_id])
    # get list of cheapest store items from grocery list
    cheap_products = StoreItem.get_cheap_store_items(@list.list_items.not_deleted)
    # fill cart with new items
    @cart = Cart.find_by(user_id: current_user)
    @cart.get_new_cart(cheap_products)
    redirect_to cart_path(@cart)
  end

  private
  def list_params
    params.require(:list).permit(:id, :name, :user_id)
  end

  def set_list
    @list = List.find(params[:id])
  end
end