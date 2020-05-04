class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home, :products, :meals, :select, :select_products, :select_recipes, :explore_recipes,
                                                  :search_recipes, :browse_category, :add_recipe, :remove_recipe, :get_list, :add_to_list]
  before_action :authenticate_admin!, only: [:dashboard, :pending]

  def home
    @list = List.new
    @categories = Recommendation.where(is_active: true).last
    # @recipes = RecipeList.where(recipe_list_type: "curated").last.recipes[0..5]
    if user_signed_in?
      @lists = current_user.lists.saved + current_user.shared_lists
      @recipe_list = current_user.get_latest_recipe_list
    end
    ahoy.track "Home", request.path_parameters
  end

  def select
    @selected_items = params[:i]
    @selected_recipes = params[:r]
    @list_id = params[:l]

    @recipes = Recipe.find(params[:r].split("&r=")) if params[:r] && params[:r].present?
    @recipe_ids = @recipes.pluck(:id).join('&r=') if params[:r] && params[:r].present?
    @temp_items = @selected_items.split("&i=").map{ |p| Item.find_by(name: p)} if params[:i]
    ahoy.track "Select", request.path_parameters
  end

  def products
    @checklist = Checklist.first
    @lists = @checklist.get_curated_lists

    @selected_items = params[:i]
    @selected_recipes = params[:r]
    @list_id = params[:l]

    @recipes = Recipe.find(params[:r].split("&r=")) if params[:r] && params[:r].present?
    @recipe_ids = @recipes.pluck(:id).join('&r=') if params[:r] && params[:r].present?
    @temp_items = @selected_items.split("&i=").map{ |p| Item.find_by(name: p)} if params[:i]
    ahoy.track "Products", request.path_parameters
  end

  def meals
    @selected_items = params[:i]
    @selected_recipes = params[:r]
    @list_id = params[:l]

    @recipes = Recipe.find(params[:r].split("&r=")) if params[:r] && params[:r].present?
    @recipe_ids = @recipes.pluck(:id).join('&r=') if params[:r] && params[:r].present?
    @temp_items = @selected_items.split("&i=").map{ |p| Item.find_by(name: p)} if params[:i]
    ahoy.track "Meals", request.path_parameters
  end

  def select_products
    @selected_items = params[:i] if params[:i]
    @selected_recipes = params[:r].join('&r=') if params[:r]
    @list_id = params[:l]
    render "select_products.js.erb"
  end

  def select_recipes
    @selected_items = params[:i].join('&i=') if params[:i]
    @selected_recipes = params[:r] if params[:r]
    @list_id = params[:l]
    render "select_recipes.js.erb"
  end

  def get_list
    @selected_items = params[:i]
    @selected_recipes = params[:r]
    @list_id = params[:l]
    render 'get_list.js.erb'
  end

  def add_recipe
    @recipe = Recipe.find(params[:recipe_id])
    render 'add_recipe.js.erb'
    ahoy.track "Add recipe", request.path_parameters
  end

  def remove_recipe
    @recipe = Recipe.find(params[:recipe_id])
    render 'remove_recipe.js.erb'
    ahoy.track "Remove recipe", request.path_parameters
  end

  def explore_recipes
    @categories = Recommendation.where(is_active: true).last
    render 'explore_recipes.js.erb'
    ahoy.track "Explore recipes", request.path_parameters
  end

  def browse_category
    @category = RecommendationItem.find(params[:category_id])
    @categories = Recommendation.where(is_active: true).last
    @recipes = @category.recipe_list.recipe_list_items.map{ |rli| rli.recipe }
    render 'browse_category.js.erb'
    ahoy.track "browse category", request.path_parameters
  end

  def search_recipes
    @categories = Recommendation.where(is_active: true).last
    @query = params[:query].present? ? params[:query] : nil
    @recipes = Recipe.search(@query, fields: [:title, :ingredients, :tags, :categories])[0..29] if @query
    render 'search_recipes.js.erb'
    ahoy.track "Search recipes", request.path_parameters
  end

  def add_to_list
    user = current_user if user_signed_in?
    params[:l].present? ? @list = List.find(params[:l]) : @list = List.create(name: "Liste de courses du #{Date.today.strftime("%d/%m")}", user: user, status: "saved", sorted_by: "rayon") if @list.nil?

    if params[:i].present?
      item_inputs = params[:i].split("&i=")
      ListItem.add_menu_to_list(item_inputs, @list)
    end

    if params[:r].present?
      recipes = Recipe.find(params[:r].split("&r="))
      recipe_item_inputs = recipes.map{ |r| r.items.pluck(:name) }.flatten
      ListItem.add_menu_to_list(recipe_item_inputs, @list)
      recipes.each{|r| r.add_recipe_to_list(@list.id)}
    end

    render 'add_to_list.js.erb'
    ahoy.track "Add to list", request.path_parameters
  end

  def thank_you
    @user = current_user
  end

  def profile
    ahoy.track "Profile", request.path_parameters
  end

  def confirmation
  end

  def dashboard
    @items_validation_size = (Item.all.list_items_to_validate.size + Item.all.recipe_items_to_validate.size)
    @list_items_verification_size = ListItem.all.no_items.size
    @reported_products = Product.where(is_reported: true).size

    @products = Product.all
    @no_food_products = Product.get_products_without_foods

    @foods = Food.all
    @foods_without_products = Food.get_foods_without_product

    @labeling = Item.where(is_validated: false).last
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
    @items = Item.where(is_validated: false).last(50)
    @items_listitems = Item.list_items_to_validate.last(50)
  end

  def verify_listitems
    @list_items = ListItem.all.select{ |it| it.item.nil?}
    @item = Item.new
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
