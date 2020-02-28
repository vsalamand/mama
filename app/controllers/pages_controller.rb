class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home]
  before_action :authenticate_admin!, only: [:dashboard, :pending]

  def home
    @list = List.new
    @recipe_list = RecipeList.new
    # @recipes = RecipeList.where(recipe_list_type: "curated").last.recipes[0..5]
    if user_signed_in?
      @recipe_lists = current_user.recipe_lists.where(status: "opened")
      @carts = current_user.carts.where.not(merchant: nil)
    end

    # get user to the thank you page if not in beta
    if user_signed_in? && current_user.beta == false
      redirect_to thank_you_path
    end
  end

  def thank_you
    @user = current_user
  end

  def profile
  end

  def confirmation
  end

  def dashboard
    @items_validation_size = Item.all.list_items_to_validate.size
    # @list_items_verification_size = ListItem.all.no_items.size
    @reported_products = Product.where(is_reported: true).size

    @products = Product.all
    @no_food_products = Product.get_products_without_foods

    @foods = Food.all
    @foods_without_products = Food.get_foods_without_product
  end

  def pending
    @recipes = Recipe.where(status: "pending")
  end

  def unmatch_foods
    @foods_without_products = Food.get_foods_without_product
  end

  def unmatch_products
    @no_food_products = Product.get_products_without_foods
  end

  def verify_items
    @list_items = Item.all.list_items_to_validate
    @recipe_items = Item.all.recipe_items_to_validate
  end

  def verify_listitems
    @list_items = ListItem.all.select{ |it| it.items.compact.empty?}
  end

  def verify_products
    @products = Product.where(is_reported: true)
  end

  def import
   StoreItem.import(params[:file])
   redirect_back(fallback_location:"/")
  end


  def products_search
    query = params[:query].present? ? params[:query] : nil
    store_id = params[:store].present? ? params[:store]['id'] : nil
    food_id = params[:food].present? ? params[:food]['id'] : nil

    if store_id.present? && food_id.present?
      @food = Food.find(food_id)
      @results = Product.search("*", page: params[:page], per_page: 50, aggs: [:stores], where: {stores: Store.find(store_id).name, food_id: @food.id})

    elsif query && store_id.present?
      @results = Product.search(query, page: params[:page], per_page: 50, aggs: [:stores], where: {stores: Store.find(store_id).name})

    elsif food_id.present?
      @food = Food.find(food_id)
      @results = Product.search("*", page: params[:page], per_page: 50, aggs: [:stores], where: {food_id: @food.id})

    else
      @results = Product.search(query, page: params[:page], per_page: 50, aggs: [:stores]) if query
    end
    # @results = search.zip(search.hits.map{ |hit| hit["_score"] }) if search
  end


end
