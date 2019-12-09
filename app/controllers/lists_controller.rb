class ListsController < ApplicationController
  before_action :set_list, only: [ :show ]
  skip_before_action :authenticate_user!, only: [:show, :get_cart]
  before_action :authenticate_admin!, only: [:index]

  def new
    @list = List.new
  end

  def create
    @list = List.new(list_params)
    @list.user_id = current_user.id
    if @list.save
      redirect_to list_path(@list)
    else
      redirect_to new_list_path
    end
  end

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
    user = current_user
    Cart.get_carts(@list, user)
    redirect_to carts_path
  end

  def share
    list = List.find(params[:list_id])
    email = params[:email]
    mail = ListMailer.share(list, email)
    mail.deliver_now
    redirect_to list_path(list)
  end


  private

  def list_params
    params.require(:list).permit(:id, :name, :user_id)
  end

  def set_list
    @list = List.find(params[:id])
  end
end
