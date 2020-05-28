require 'open-uri'
require 'hangry'


class RecipesController < ApplicationController
  before_action :set_recipe, only: [ :show, :card, :edit, :update, :set_published_status, :set_dismissed_status, :god_show ]
  skip_before_action :authenticate_user!, only: [ :show, :card, :cart, :select_all]
  before_action :authenticate_admin!, only: [:new, :import, :create, :import, :god_show ]

  def show
    @list_item = ListItem.new
    @list = List.find(params[:l]) if params[:l].present?

    @referrer = params[:ref]
    if @referrer.nil? || @referrer == request.url
      @referrer = "/explore"
    end

    respond_to do |format|
      format.html
    end
    ahoy.track "Show recipe", recipe_id: @recipe.id, title: @recipe.title
  end

  def select_all
    @recipe = Recipe.find(params[:id])
    render "select_all.js.erb"
    ahoy.track "Select all recipe items", recipe_id: @recipe.id, title: @recipe.title
  end

  def god_show
  end

  def new
    @recipe = Recipe.new
  end

  def index
    @recipes = current_user.recipes.uniq
  end

  def import
    @recipe = Recipe.new
  end

  def import_recipes
   Recipe.import(params[:file])
   redirect_back(fallback_location:"/")
  end

  def search
    # @recipes = Recipe.where(status: "published")
    @query = params[:query].present? ? params[:query] : nil

    @results = Recipe.search(@query, fields: [:title, :ingredients, :tags, :categories])[0..29] if @query

    respond_to do |format|
      format.html
      format.js
    end
  end

  def create
    @recipe = Recipe.new(recipe_params)
    @recipe.status = "pending"
    if @recipe.title.nil?
      recipe_parser(@recipe.link)
      @recipe.title = @recipe.title.downcase.capitalize
      if @recipe.save
        Item.add_recipe_items(@recipe)
        redirect_to pending_path
      else
        redirect_to import_recipes_path
      end
    else
      @recipe.origin = "mama" if @recipe.origin.blank?
      @recipe.title = @recipe.title.downcase.capitalize
      if @recipe.save
        Item.add_recipe_items(@recipe)
        redirect_to pending_path
      else
        redirect_to new_recipe_path
      end
    end
  end

  def set_published_status
    @recipe.status = "published"
    # generate_ingredients_tags(@recipe)
    @recipe.save
    @recipe.items.each{ |item| item.validate }
    # @recipe.upload_to_cloudinary
    redirect_to recipe_path(@recipe)
  end

  def set_dismissed_status
    @recipe.status = "dismissed"
    @recipe.save
    @recipe.items.each{ |item| item.unvalidate }
    redirect_to recipe_path(@recipe)
  end


  def edit
  end

  def update
    @recipe.update(recipe_params)
    redirect_to recipe_path(@recipe)
  end


  def cart
    @recipe = Recipe.find(params[:id])
    @store = Store.find(params[:store_id])
  end

  def add_to_list
    @recipe = Recipe.find(params[:id])
    params[:list_id] ? @list = List.find(params[:list_id]) : @list = List.create(name: "Liste de courses du #{Date.today.strftime("%d/%m")}", user: user, status: "saved", sorted_by: "rayon") if @list.nil?

    items = params[:items]

    ListItem.add_menu_to_list(items, @list)

    render 'add_to_list.js.erb'
    ahoy.track "Create list from recipe", request.path_parameters
  end

  def fetch_suggested_recipes
    # @recipes = RecipeList.where(recipe_list_type: "curated").last.recipes[0..20]
    @recipes = RecipeList.get_curated_recipes

    render 'fetch_suggested_recipes.js.erb'
  end

  def fetch_recipe_card
    @recipe = Recipe.find(params[:id])
    @context = params[:referrer]
    render 'fetch_recipe_card.js.erb'
  end

  def fetch_menu
    @menu = current_user.get_menu
    # @recipes = menu.recipes
    render 'fetch_menu.js.erb'
  end

  def add_to_menu
    @recipe = Recipe.find(params[:id])
    @recipe_list = RecipeList.find(params[:recipe_list_id])

    @recipe.add_to_recipe_list(@recipe_list)

    render 'add_to_menu.js.erb'
    ahoy.track "Add recipe", request.path_parameters
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


  private

  def set_recipe
    @recipe = Recipe.find(params[:id])
  end

  def recipe_params
    params.require(:recipe).permit(:title, :servings, :ingredients, :instructions, :tag_list, :origin, :status, :link, :rating, recipe_list_ids: [], recipe_list_items_attributes:[:name, :recipe_list_id, :recipe_id])
  end

end
