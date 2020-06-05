class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home, :browse, :products, :meals, :select, :select_products, :select_recipes, :explore_recipes,
                                                  :search_recipes, :browse_category, :add_recipe, :remove_recipe, :get_list,
                                                  :add_to_list, :add_to_list_modal, :explore, :select_list, :fetch_ios_install, :fetch_android_install]
  before_action :authenticate_admin!, only: [:dashboard, :pending]

  def home
    if user_signed_in?
      redirect_to browse_path
    else
      ahoy.track "Landing"
    end
  end

  def browse
    @categories = Recommendation.where(is_active: true).last

    if user_signed_in?
      @lists = current_user.get_lists
      @recipe_list = current_user.get_latest_recipe_list
      ahoy.track "Browse"
    else
      redirect_to explore_path
    end
  end

  def cuisine
    if user_signed_in?
      @latest_recipe = current_user.recipe_list_items.last.recipe if current_user.recipe_list_items.any?
      @favorites = current_user.get_latest_recipe_list
      @favorite_recipe = @favorites.recipe_list_items.last.recipe if @favorites.recipe_list_items.any?
      ahoy.track "Cuisine"
    else
      redirect_to explore_path
    end
  end

  def explore
    @checklist = Checklist.find_by(name: "templates")
    @lists = @checklist.get_curated_lists
    recipe_idea_id = RecipeList.where(recipe_list_type: "curated").map{ |rl| rl.recipes.pluck(:id)}.flatten.shuffle[0]
    @recipe_idea = Recipe.find(recipe_idea_id)
    @categories = Recommendation.where(is_active: true).last

    ahoy.track "Explore"
  end

  def history
    @recipes = current_user.recipe_list_items.last(50).reverse.map{ |rli| rli.recipe}.uniq
    ahoy.track "History"
  end

  def favorites
    @recipes = current_user.get_latest_recipe_list.recipes
    ahoy.track "Favorites"
  end

  def select
    @selected_items = params[:i].join("&i=") if params[:i]

    @pr = Recipe.find(params[:pr]) if params[:pr].present?
    @selected_recipes = @pr.id if @pr.present?

    @pl = List.find(params[:pl]) if params[:pl].present?
    @selected_recipes = @pl.recipes.pluck(:id).join('&r=') if @pl.present? && @pl.recipes.any?

    @recipes = Recipe.find(params[:r].split("&r=")) if params[:r] && params[:r].present?

    @list = List.find(params[:l]) if params[:l].present?
    if @list.present?
      redirect_to add_to_list_path(l: @list.id, r: @pr, i: @selected_items)
    else
      ahoy.track "Select"
    end
  end

  # def products
  #   @checklist = Checklist.find_by(name: "products")
  #   @lists = @checklist.get_curated_lists

  #   @selected_items = params[:i]
  #   @selected_recipes = params[:r]
  #   @list_id = params[:l]

  #   @recipes = Recipe.find(params[:r].split("&r=")) if params[:r] && params[:r].present?
  #   @recipe_ids = @recipes.pluck(:id).join('&r=') if params[:r] && params[:r].present?
  #   @temp_items = @selected_items.split("&i=").map{ |p| Item.find_by(name: p)} if params[:i]
  #   ahoy.track "Products"
  # end

  def meals
    @selected_items = params[:i]
    @selected_recipes = params[:r]
    @list = List.find(params[:l]) if params[:l].present?
    # @list_id = params[:l]

    @categories = Recommendation.where(is_active: true).last
    @category = RecommendationItem.find(params[:category_id]) if params[:category_id].present?

    if @category.present?
      @recipes = @category.recipe_list.recipe_list_items.map{ |rli| rli.recipe }.sort_by(&:title)
      ahoy.track "browse category", name: @category.name
    elsif params[:query].present?
      @query = params[:query].present? ? params[:query] : nil
      @recipes = Recipe.search(@query, fields: [:title, :ingredients, :tags, :categories])[0..49] if @query
      ahoy.track "Search", query: @query
    else
      @recipes = RecipeListItem.get_most_popular
      ahoy.track "browse category", name: "most popular"
    end
    # ahoy.track "Meals", request.path_parameters
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

    if params[:c] == "list"
      @pl = List.find(params[:s])
    elsif params[:c] == "recipe"
      @pr = Recipe.find(params[:s])
    end

    render 'get_list.js.erb'
  end

  def add_recipe
    @recipe = Recipe.find(params[:recipe_id])
    render 'add_recipe.js.erb'
    ahoy.track "Add recipe", recipe_id: @recipe.id, title: @recipe.title
  end

  def remove_recipe
    @recipe = Recipe.find(params[:recipe_id])
    render 'remove_recipe.js.erb'
    ahoy.track "Remove recipe", recipe_id: @recipe.id, title: @recipe.title
  end

  # def explore_recipes
  #   @categories = Recommendation.where(is_active: true).last
  #   render 'explore_recipes.js.erb'
  #   ahoy.track "Explore recipes", request.path_parameters
  # end



  def add_to_list
    user = current_user if user_signed_in?
    (params[:l].present? && params[:l] != "0") ? @list = List.find(params[:l]) : @list = List.create(name: "Liste de courses du #{Date.today.strftime("%d/%m")}", user: user, status: "saved", sorted_by: "rayon") if @list.nil?

    if params[:i].present?
      item_inputs = params[:i].split("&i=")
      ListItem.add_menu_to_list(item_inputs, @list)
    end

    if params[:r].present?
      recipes = Recipe.find(params[:r].split("&r="))
      # recipe_item_inputs = recipes.map{ |r| r.items.pluck(:name) }.flatten
      # ListItem.add_menu_to_list(recipe_item_inputs, @list)
      recipes.each{|r| r.add_recipe_to_list(@list.id)}
    end

    respond_to do |format|
      format.html { redirect_to list_path(@list) }
      format.js { render 'add_to_list.js.erb' }
    end

    # render 'add_to_list.js.erb'
    ahoy.track "Add to list", list_id: @list.id, name: @list.name, items: params[:i]
  end

  # def add_to_list_modal
  #   @recipe = Recipe.find(params[:r])
  #   @list = List.find(params[:l]) if params[:l].present?

  #   render "add_to_list_modal.js.erb"
  #   ahoy.track "Open Add to list modal", recipe_id: @recipe.id, title: @recipe.title
  # end

  def select_list
    @list = List.find(params[:l]) if params[:l].present? && params[:l] != "0"
    render "select_list.js.erb"
  end

  def add_to_favorites
    @recipe = Recipe.find(params[:r])
    @recipe_list = current_user.get_latest_recipe_list

    @recipe.add_to_recipe_list(@recipe_list)
    render 'add_to_favorites.js.erb'
    ahoy.track "Add to favorites", recipe_id: @recipe.id, title: @recipe.title
  end

  def remove_from_favorites
    @recipe = Recipe.find(params[:r])
    @recipe_list = current_user.get_latest_recipe_list
    @recipe_list_item = RecipeListItem.find_by(recipe_id: @recipe.id, recipe_list_id: @recipe_list.id)

    if @recipe_list_item.present?
      @recipe_list_item.destroy
      render 'remove_from_favorites.js.erb'
      ahoy.track "Remove from favorites", recipe_id: @recipe.id, title: @recipe.title
    end
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

  def fetch_ios_install
    render 'fetch_ios_install.js.erb'
  end

  def fetch_android_install
    render 'fetch_android_install.js.erb'
  end

end
