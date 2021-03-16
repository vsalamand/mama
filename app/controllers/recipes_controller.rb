require 'open-uri'
require 'hangry'
require 'yaml'


class RecipesController < ApplicationController
  before_action :set_recipe, only: [ :show, :card, :edit, :update, :set_published_status, :set_dismissed_status, :god_show, :click ]
  skip_before_action :authenticate_user!, only: [:fetch_recipes, :recommend, :next, :click ]
  before_action :authenticate_admin!, only: [:new, :show, :import, :create, :import, :god_show, :manage, :analytics]

  def show
    @list = List.find(params[:l]) if params[:l].present?

    @recipe.servings.nil? ? @servings = 1 : @servings = @recipe.servings.delete('^0-9').to_i

    if user_signed_in?
      @lists = current_user.get_lists
    end

    @referrer = params[:ref]
    # @referrer = list_path(@list) if @list.present?
    @referrer = list_path(@list, type: params[:type], content: params[:content]) if @list.present?
    if @referrer.nil? || @referrer == request.url || @referrer.include?("/recipes")
      @referrer = "/"
    end


    respond_to do |format|
      format.html
      format.js
    end
    ahoy.track "Show recipe", recipe_id: @recipe.id, title: @recipe.title
  end

  def select_all
    @recipe = Recipe.friendly.find(params[:id])
    render "select_all.js.erb"
    ahoy.track "Select all recipe items", recipe_id: @recipe.id, title: @recipe.title
  end

  def god_show
  end

  def new
    @recipe = Recipe.new
  end

  def index
    # @recipes = current_user.recipes.uniq

    redirect_to root_path
  end

  def import
    @recipe = Recipe.new
  end

  def import_recipes
    Recipe.import(params[:file])
    redirect_to pending_path
  end

  def manage
    @categories = RecipeList.curated
    @category = RecipeList.find(params[:category_id]) if params[:category_id].present?
    @query = params[:query]
    @recipe_list_item = RecipeListItem.new

    if @category.present?
      @recipes = @category.recipes.paginate(page: params[:page], per_page: 100)
    elsif params[:pending].present?
      @recipes = Recipe.where(status: "pending").order(:id).reverse.paginate(page: params[:page], per_page: 100)
    elsif @query.present?
      @recipes = Recipe.search(@query, fields: [:title], page: params[:page], per_page: 100) if @query
    else
      @recipes = Recipe.where(status: "published").order(:id).reverse.paginate(page: params[:page], per_page: 100)
    end

    respond_to do |format|
      format.html
      format.js
    end
  end

  def edit_modal
    @recipe = Recipe.find(params[:id])
    @recipe_list_items = @recipe.get_curated_recipe_list_items
    @recipe_list_item = RecipeListItem.new
    render "edit_modal.js.erb"
  end

  def create
    @recipe = Recipe.new(recipe_params)
    @recipe.status = "pending"

    if @recipe.title.nil?
      @recipe.scrape
      if @recipe.save
        Thread.new do
          Item.add_recipe_items(@recipe)
        end
        redirect_to pending_path
      else
        flash[:notice] = "Impossible d'importer ce type de lien pour le moment"
        redirect_to import_recipes_path
      end

    else
      @recipe.origin = "mama" if @recipe.origin.blank?
      @recipe.title = @recipe.title.downcase.capitalize
      if @recipe.save
        Item.add_recipe_items(@recipe)
        redirect_to pending_path
      else
        flash[:notice] = "Il y a eu une erreur, la recette n'a pas été créée"
        redirect_to new_recipe_path
      end
    end
  end

  def set_published_status
    @recipe.publish
    # generate_ingredients_tags(@recipe)
    # @recipe.save
    @recipe.items.each{ |item| item.validate }
    # @recipe.upload_to_cloudinary

    respond_to do |format|
      format.html { redirect_back(fallback_location:"/") }
      format.js { render 'set_published_status.js.erb' }
    end
  end

  def set_dismissed_status
    @recipe.status = "dismissed"
    @recipe.save
    # @recipe.items.each{ |item| item.unvalidate }
    respond_to do |format|
      format.html { redirect_back(fallback_location:"/") }
      format.js { render 'set_dismissed_status.js.erb' }
    end
  end


  def edit
  end

  def update
    @recipe.update(recipe_params)
    redirect_to recipe_path(@recipe)
  end


  def cart
    @recipe = Recipe.friendly.find(params[:id])
    @store = Store.find(params[:store_id])
  end

  def add_to_list
    @recipe = Recipe.friendly.find(params[:id])
    params[:l] != "0" ? @list = List.find(params[:l]) : @list = List.create(name: @recipe.title, user: current_user, status: "saved", sorted_by: "rayon") if @list.nil?

    params[:i] ? items = params[:i] : items = @recipe.items.pluck(:name)

    Item.add_menu_to_list(items, @list)

    @recipe.add_recipe_to_list(@list.id)


    respond_to do |format|
      format.html { redirect_to list_path(@list) }
      format.js { render 'add_to_list.js.erb' }
    end

    ahoy.track "Create list from recipe", request.path_parameters
  end

  def fetch_suggested_recipes
    # @recipes = RecipeList.where(recipe_list_type: "curated").last.recipes[0..20]
    @recipes = RecipeList.get_curated_recipes

    render 'fetch_suggested_recipes.js.erb'
  end

  def fetch_recipe_card
    @recipe = Recipe.friendly.find(params[:id])
    @context = params[:referrer]
    render 'fetch_recipe_card.js.erb'
  end

  def fetch_menu
    @menu = current_user.get_menu
    # @recipes = menu.recipes
    render 'fetch_menu.js.erb'
  end

  def add_to_menu
    @recipe = Recipe.friendly.find(params[:id])
    @recipe_list = RecipeList.find(params[:recipe_list_id])

    @recipe.add_to_recipe_list(@recipe_list)

    respond_to do |format|
      format.html { redirect_back(fallback_location:"/") }
      format.js { render 'add_to_menu.js.erb' }
    end

    ahoy.track "Add recipe", request.path_parameters
  end

  def categorize
    category = params[:c]
    @recipe = Recipe.friendly.find(params[:id])

    if @recipe.tag_list.include?(category)
      @recipe.tag_list = ""
      @recipe.save
    else
      @recipe.tag_list = category
      @recipe.save
    end

    respond_to do |format|
      format.html { redirect_back(fallback_location:"/") }
      format.js { render 'categorize.js.erb' }
    end
  end

  def add_menu_to_list
    @menu = current_user.get_menu
    params[:list_id] ? @list = List.find(params[:list_id]) : @list = List.create(name: "Liste de courses #{current_user.lists.size + 1}", user: current_user, status: "opened") if @list.nil?

    ListItem.add_menu_to_list(@menu.items, @list)

    @menu.archive

    if @menu.recipes.any?
      flash[:notice] = 'Les recettes sont disponibles dans la rubrique "Vos menus"'
    end

    render "add_menu_to_list.js.erb"
  end

  def destroy
    @recipe = Recipe.friendly.find(params[:id])
    @recipe.destroy
    respond_to do |format|
      format.html { redirect_back(fallback_location:"/") }
      format.js { render 'destroy.js.erb' }
    end
  end

  def update_servings
    @recipe = Recipe.friendly.find(params[:id])
    @servings = params[:s].to_i
    @servings_delta = params[:s].to_f / @recipe.servings.delete('^0-9').to_f
    render "update_servings.js.erb"
  end

  def fetch_recipes
    # query = Array(params[:q])
    # if params[:l].present?
    #   @list = List.friendly.find(params[:l])
    #   query = @list.items.not_deleted.where(is_completed: false).pluck(:name) if params[:q].nil?
    # end
    # if query.present?
    #   @recipes = Recipe.multi_search(query)[0..49]
    # end
    # if params[:source]
    #   @source_id = params[:source].gsub(/[^0-9]/, '')
    #   @source_type = params[:source].gsub(/[^a-z]/, '')
    # end
    type = params[:t]
    input_ids = params[:i]

    if type == "v"
      @recipes = Recipe.search_by_categories(input_ids)[0..49]
    elsif type == "u"
      @recipes = Recipe.search_by_categories(Item.find(input_ids).pluck(:category_id).compact)[0..49]
    end

    render "fetch_recipes.js.erb"
  end

  def recommend
    type = params[:t]
    query_ids = params[:i]

    if query_ids.present?
      if type == "u"
        @category_ids = Item.find(query_ids).pluck(:category_id).compact
      else
        @category_ids = query_ids.reject(&:empty?).map(&:to_i)
      end
    else
      @category_ids = []
    end

    @recipe_ids = Recipe.recommend(@category_ids, current_user).map{|x| x["id"]}

    @recipes = Recipe.find(@recipe_ids.take(2))

    @recipes.each{ |recipe| ahoy.track "Recommend recipe", recipe_id: recipe.id, title: recipe.title }

    render "recommend.js.erb"
  end

  def next
    @category_ids = YAML.load(params[:c])
    @recipe_ids = YAML.load(params[:r]).drop(2)
    @recipe_ids = Recipe.recommend(@category_ids, current_user).map{|x| x["id"]} if @recipe_ids.size < 2

    @recipes = Recipe.find(@recipe_ids.take(2))


    @recipes.each{ |recipe| ahoy.track "Recommend recipe", recipe_id: recipe.id, title: recipe.title }

    render "recommend.js.erb"
  end

  def click
    ahoy.track "Click recipe", recipe_id: @recipe.id, title: @recipe.title
  end

 def analytics
    @impressions = Ahoy::Event.where(name: "Recommend recipe")
    @impressions_per_recipe = []
    @impressions.pluck(:properties).inject({}) { |sum, val| sum[val["recipe_id"]] = sum[val["recipe_id"]].to_i + 1; sum }.each{|key, value| @impressions_per_recipe << {:recipe_id => key, :count => value} }
    @impressions_per_recipe = @impressions_per_recipe.sort_by { |k| k[:count] }.reverse

    @clicks = Ahoy::Event.where(name: "Click recipe")
    @clicks_per_recipe = []
    @clicks.pluck(:properties).inject({}) { |sum, val| sum[val["recipe_id"]] = sum[val["recipe_id"]].to_i + 1; sum }.each{|key, value| @clicks_per_recipe << {:recipe_id => key, :count => value} }
    @clicks_per_recipe = @clicks_per_recipe.sort_by { |k| k[:count] }.reverse
  end

  def visualization
    @list = current_list
    @saved_items = @list.get_saved_items
    @categories = @list.get_suggestions
  end

  def visualize
    type = params[:t]
    if type == "u"
      @category_ids = Item.find(params[:i]).pluck(:category_id).compact
    else
      @category_ids = params[:i].reject(&:empty?).map(&:to_i)
    end

    @recipes_hashes = Recipe.recommend(@category_ids, nil)

    @user_recipes_hashes = Recipe.recommend(@category_ids, current_user)

    render "visualize.js.erb"
  end

  private

  def set_recipe
    @recipe = Recipe.friendly.find(params[:id])
  end


  def recipe_params
    params.require(:recipe).permit(:title, :servings, :ingredients, :instructions, :tag_list, :origin, :status, :link, :image_url, :rating, recipe_list_ids: [], recipe_list_items_attributes:[:name, :recipe_list_id, :recipe_id])
  end

end
