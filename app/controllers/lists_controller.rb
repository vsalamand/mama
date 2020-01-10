class ListsController < ApplicationController
  before_action :set_list, only: [ :show ]
  skip_before_action :authenticate_user!, only: [:accept_invite]

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

  def edit
  end

  def update
    @list = List.find(params[:id])
    @list.update(list_params)
    redirect_to list_path(@list)
  end

  def index
    @lists = current_user.lists
    @shared_lists = current_user.shared_lists
    @list = List.new
  end

  def show
    @list = List.find(params[:id])
    @list_item = ListItem.new
    @list_items = @list.list_items.not_deleted
    @list_foods = @list_items.map{ |item| item.food }.flatten
    @curator_lists = User.find_by_email("mama@clubmama.co").lists
    @collaboration = Collaboration.new
    # @recipes = RecipeList.where(recipe_list_type: "curated").last.recipes[0..9]
  end

  def fetch_suggested_items
    @list = List.find(params[:list_id])
    render 'fetch_suggested_items.js.erb'
  end

  # def fetch_recipes
  #   @list = List.find(params[:list_id])
  #   @list_item = ListItem.new
  #   @recipes = RecipeList.where(recipe_list_type: "curated").last.recipes
  #   render 'fetch_recipes.js.erb'
  # end

  def get_cart
    @list = List.find(params[:list_id])
    user = current_user
    Cart.get_carts(@list, user)
    redirect_to carts_path
  end

  def share
    list = List.find(params[:list_id])
    email = params[:emailShare]
    mail = ListMailer.share(list, email)
    mail.deliver_now
    redirect_to list_path(list)
  end

  def send_invite
    list = List.find(params[:list_id])
    email = params[:email]
    mail = ListMailer.send_invite(list, email)
    mail.deliver_now
    redirect_to list_path(list)
  end

  def accept_invite
    list = List.find(params[:list_id])
    user = User.find_by(email: params[:user_email])
    if user
      collab = Collaboration.new(list: list, user: user)
      if collab.save
        redirect_to list_path(list)
      else
        redirect_to list_path(list)
      end
    else
      redirect_to new_user_registration_path(:shared_list => list.id, :user_email => params[:user_email])
    end
  end

  def destroy
    @list = List.find(params[:id])
    @list.destroy
    redirect_to lists_path
  end


  private

  def list_params
    params.require(:list).permit(:id, :name, :user_id)
  end

  def set_list
    @list = List.find(params[:id])
  end
end
