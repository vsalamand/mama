class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home]
  before_action :authenticate_admin!, only: [:dashboard, :pending]

  def home
    @list = List.new
    @recipes = RecipeList.where(recipe_list_type: "curated").last.recipes[0..5]

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
    @items_validation_size = ListItem.all.to_validate.size
    @list_items_verification_size = ListItem.all.no_items.size
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
    @list_items = ListItem.all.to_validate
  end

  def verify_listitems
    @list_items = ListItem.all.no_items
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
    search = Product.search(query) if query
    @results = search.zip(search.hits.map{ |hit| hit["_score"] }) if search
  end

end
