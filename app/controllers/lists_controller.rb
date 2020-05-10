class ListsController < ApplicationController
  before_action :set_list, only: [ :show ]
  skip_before_action :authenticate_user!, only: [:accept_invite, :show, :sort, :edit, :update, :remove_recipe]


  def new
    @list = List.new
  end

  def create
    @list = List.new(list_params)
    # @list.user_id = current_user.id
    # @list.status = "opened"
    if @list.save
      redirect_to lists_path if @list.list_type == "curated"
      redirect_to list_path(@list) if @list.list_type == "personal"
      ahoy.track "Create list", request.path_parameters
    else
      redirect_to new_list_path
    end
  end

  def copy
    @list = List.find(params[:list_id])

    if @list.user.nil?
      @list.user = current_user
      @list.save
      redirect_to list_save_path(@list)

    else
      @new_list = @list.duplicate_list(current_user)
      ListItem.add_menu_to_list(@list.list_items.not_deleted.pluck(:name), @new_list)
      redirect_to list_save_path(@new_list)
    end
  end

  def add
    @list = List.find(params[:list_id])
    @items = params[:items]

    ListItem.add_menu_to_list(@items, @list)

    render 'add.js.erb'
    ahoy.track "Add list items", request.path_parameters
  end

  def edit
  end

  def update
    @list = List.find(params[:id])
    @list.update(list_params)
    @all_list_items = []
    flash[:notice] = 'La liste est enregistrée !'
    redirect_to lists_path if @list.list_type == "curated"
    redirect_to list_path(@list) if @list.list_type == "personal"
    ahoy.track "Update list", request.path_parameters
  end

  def index
    # @lists = current_user.lists.saved
    # @shared_lists = current_user.shared_lists
    @lists = List.where(list_type: "curated", status: "saved")
    @list = List.new
  end

  def show
    @list = List.find(params[:id])
    @list_items = @list.list_items.not_deleted
    # @uncomplete_list_items = @list.get_items_to_buy
    @list_item = ListItem.new
    @recipes = @list.recipes

    if user_signed_in?
      @lists = current_user.lists.saved + current_user.shared_lists - Array(@list)
      @list_foods = @list_items.not_completed.map{ |item| item.food }.flatten
      @collaboration = Collaboration.new
      @recipe_list = RecipeList.new
    end

    # @recipes = RecipeList.where(recipe_list_type: "curated").last.recipes[0..9]
    ahoy.track "Show list", request.path_parameters
  end

  def fetch_suggested_items
    @list = List.find(params[:list_id])
    render 'fetch_suggested_items.js.erb'
  end

  def get_suggested_items
    @list = List.find(params[:list_id])
    @checklists = Checklist.first.get_curated_lists

    render 'get_suggested_items.js.erb'
  end

  def fetch_price
    @list = List.find(params[:list_id])
    @carts_price = Store.get_cheapest_store_price(@list)

    render 'fetch_price.js.erb'
  end

  def get_store_carts
    @list = List.find(params[:list_id])
    @list.get_store_carts
    redirect_to store_carts_path(:list_id => @list.id)
  end

  def sort
    @list = List.find(params[:list_id])
    @list.update_column(:sorted_by, params[:sort_option])

    render 'sort.js.erb'
    ahoy.track "Sort list", request.path_parameters
  end

  def remove_recipe
    @list = List.find(params[:list_id])
    @recipe = Recipe.find(params[:recipe_id])
    RecipeListItem.find_by(recipe_id: params[:recipe_id], list_id: @list.id).destroy

    render 'remove_recipe.js.erb'
    ahoy.track "Remove recipe", request.path_parameters
  end


  # def fetch_recipes
  #   @list = List.find(params[:list_id])
  #   @list_item = ListItem.new
  #   @recipes = RecipeList.where(recipe_list_type: "curated").last.recipes
  #   render 'fetch_recipes.js.erb'
  # end

  # def get_cart
  #   @list = List.find(params[:list_id])
  #   user = current_user
  #   Cart.get_carts(@list, user)
  #   redirect_to carts_path
  # end

  def share
    list = List.find(params[:list_id])
    recipes = list.recipes
    params[:emailShare].present? ? email = params[:emailShare] : email = current_user.email
    mail = ListMailer.share(list, email, recipes)
    mail.deliver_now

    head :ok
  end

  def send_invite
    list = List.find(params[:list_id])
    email = params[:email]
    mail = ListMailer.send_invite(list, email)
    mail.deliver_now
    redirect_to list_path(list)
    ahoy.track "Send invite", request.path_parameters
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
    ahoy.track "Accept invite", request.path_parameters
  end

  def archive
    list = List.find(params[:list_id])
    list.archive
    redirect_to root_path
  end

  def destroy
    @list = List.find(params[:id])
    @list.delete
    flash[:notice] = 'La liste a été supprimée.'
    redirect_to lists_path if @list.list_type == "curated"
    redirect_to root_path if @list.list_type == "personal"
    ahoy.track "Destroy list", request.path_parameters
  end

  def save
    @list = List.find(params[:list_id])
    @list.saved

    ahoy.track "Save list", request.path_parameters
  end


  private

  def list_params
    params.require(:list).permit(:id, :name, :user_id, :status, :list_type)
  end

  def set_list
    @list = List.find(params[:id])
  end
end
