class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home, :browse, :cuisine, :products, :meals, :select_products, :select_recipes, :explore_recipes,
                                                  :search_recipes, :browse_category, :add_recipe, :remove_recipe, :get_list,
                                                  :add_to_list, :add_to_list_modal, :explore, :select_list, :fetch_ios_install, :fetch_android_install,
                                                  :start, :fetch_landing, :assistant, :add_to_homescreen, :beta, :check_user]
  before_action :authenticate_admin!, only: [:dashboard, :pending, :users, :verify_items, :add_to_beta ]


  def home
    if params[:mode].present?
      ahoy.track "Webapp launch"
    end

    if user_signed_in?
      if current_user.beta
        redirect_to browse_path
      else
        # redirect if current user is not in beta
        redirect_to assistant_path
      end
    else
      ahoy.track "Landing"
    end
  end

  def assistant
    if current_user
      @list = current_user.get_assistant
      @saved_items = @list.get_saved_items
      @categories = @list.get_suggestions
    else
      @categories = Category.get_suggestions
    end
    ahoy.track "Assistant"
  end

  def refresh_assistant
    @categories = Category.get_top_recipe_categories.shuffle[0..7]
    @selected_categories = params[:c].compact if params[:c].present?
    render "refresh_assistant.js.erb"
  end

  def cuisine
    recipe_idea_id = RecipeList.where(recipe_list_type: "curated").map{ |rl| rl.recipes.pluck(:id)}.flatten.shuffle[0]
    @recipe = Recipe.find(recipe_idea_id)
    @selected_categories = params[:c].compact if params[:c].present?

    ahoy.track "Cuisine"
  end

  def refresh_meal
    recipe_idea_id = RecipeList.where(recipe_list_type: "curated").map{ |rl| rl.recipes.pluck(:id)}.flatten.shuffle[0]
    @recipe = Recipe.find(recipe_idea_id)
    @selected_categories = params[:c].compact if params[:c].present?
    render "refresh_meal.js.erb"
  end


  def browse
    # redirect if current user is not in beta
    redirect_to assistant_path unless current_user.beta

    @list = List.new

    if user_signed_in?
      @lists = current_user.get_lists
      current_user.reset_current_list
    end


    ahoy.track "Browse"
  end


  def explore
    # get last published recipes
    @weekly_menu = Recommendation.find_by(name: "Featured").recipe_lists.last
    @recipes = @weekly_menu.recipe_list_items.sort_by(&:id).map{ |rli| rli.recipe }.reverse.select{|r| r.is_published?}

    # redirect_to root_path
    ahoy.track "Explore"
  end

  # def history
  #   @recipes = current_user.recipe_list_items.last(50).reverse.map{ |rli| rli.recipe}.uniq
  #   ahoy.track "History"
  # end

  def favorites
    @recipes = current_user.get_latest_recipe_list.recipes.order(:title)
    # redirect_to root_path
    ahoy.track "Favorites"
  end

  def select
    @selected_items = params[:i].join("&i=") if params[:i]

    @pr = Recipe.friendly.find(params[:pr]) if params[:pr].present?
    @selected_recipes = @pr.id if @pr.present?

    @pl = List.friendly.find(params[:pl]) if params[:pl].present?
    @selected_recipes = @pl.recipes.pluck(:id).join('&r=') if @pl.present? && @pl.recipes.any?

    @recipes = Recipe.find(params[:r].split("&r=")) if params[:r] && params[:r].present?

    @list = List.friendly.find(params[:l]) if params[:l].present?
    @lists = current_user.get_lists

    if @list.present?
      redirect_to add_to_list_path(l: @list.id, r: @selected_recipes, i: @selected_items)
    else
      ahoy.track "Select"
    end
  end

  def products
    @checklist = Checklist.find_by(name: "templates")
    @checklists = @checklist.get_curated_lists
    @list_id = params[:l] if params[:l].present?

    ahoy.track "Products"
  end

  def meals
    @selected_items = params[:i]
    @selected_recipes = params[:r]
    @list = List.find(params[:l]) if params[:l].present?
    # @list_id = params[:l]

    @categories = Recommendation.find_by(name: "Categories")
    @category = RecommendationItem.find(params[:category_id]) if params[:category_id].present?

    if @category.present?
      @recipes = @category.recipe_list.recipe_list_items.map{ |rli| rli.recipe }.sort_by(&:id).reverse.select{|r| r.is_published?}
      ahoy.track "browse category", name: @category.name

    elsif params[:query].present?
      @query = params[:query].present? ? params[:query] : nil
      @recipes = Recipe.where(status: "published").search(@query, fields: [:title, :ingredients])[0..49] if @query
      ahoy.track "Search", query: @query

    elsif params[:favorites].present?
      @recipes = current_user.get_latest_recipe_list.recipes if user_signed_in?
      ahoy.track "Favorites"

    elsif params[:history].present?
      if user_signed_in?
        recipe_list_items = current_user.recipe_list_items + current_user.get_lists.map{ |l| l.recipe_list_items}.flatten
        @recipes = recipe_list_items.last(50).reverse.map{ |rli| rli.recipe}.uniq
      end
      ahoy.track "History"

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
    # @selected_recipes = params[:r]
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
    (params[:l].present? && params[:l] != "0") ? @list = List.find(params[:l]) : @list = List.create(name: "Liste de courses semaine #{Date.today.strftime("%U")}", user: user, status: "saved", sorted_by: "rayon")

    if params[:i].present?
      item_inputs = params[:i].split("&i=")
      Item.add_menu_to_list(item_inputs, @list)
    end

    if params[:r].present?
      recipes = Recipe.friendly.find(params[:r].split("&r="))
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
    @recipe.add_to_favorites(current_user)

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

  def activity
    @user = current_user
    @score = @user.scores.first.value

    if params[:l]
      list = List.find(params[:l])
      @items = list.items
    else
      @items = @user.get_items
    end

    @data = ItemHistory.get_score_progress(@items, @score, 150)

    @good_products = @items.where(is_completed: false, is_deleted: false).where(category_id: Category.where(rating: 1).pluck(:id))
    @limit_products = @items.where(is_completed: false, is_deleted: false).where(category_id: Category.where(rating: 2).pluck(:id))
    @avoid_products = @items.where(is_completed: false, is_deleted: false).where(category_id: Category.where(rating: 3).pluck(:id))


    ahoy.track "Activity", user_id: @user.id, email: @user.email
  end

  def get_score
    @score = current_user.get_score
    render "get_score.js.erb"
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
    @recommend = RecipeList.find_by(recipe_list_type: "curated", name: "Idées repas")
  end

  def unmatch_foods
    @foods_without_products = Food.get_foods_without_product
  end

  def unmatch_products
    @no_food_products = Product.get_products_without_foods
  end

  def verify_items
    @items = Item.where(is_validated: false).last(100)
    @items_listitems = Item.where(is_validated: true).last(100)
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

  def start
    @context = params[:c] if params[:c].present?
    render 'user_start.js.erb'
    ahoy.track "Start"
  end

  def check_user
    @email = params[:e]
    user = User.find_by(email: @email)
    @context = params[:c]

    if user.present?
      # render login form
      render 'user_login.js.erb'
      ahoy.track "Login"
    else
      # render signup form
      render 'user_signup.js.erb'
      ahoy.track "Signup"
    end
  end

  def fetch_landing
    render 'fetch_landing.js.erb'
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

  def users
    @users = User.all
    @beta_users = User.where(beta: true)
  end

  def add_to_beta
    @user = User.find(params[:id])
    @user.add_to_beta
    redirect_to users_path
  end

  def fetch_ios_install
    render 'fetch_ios_install.js.erb'
  end

  def fetch_android_install
    render 'fetch_android_install.js.erb'
  end

  def add_to_homescreen
    @device = params[:device]
  end

  def beta

  end

end
