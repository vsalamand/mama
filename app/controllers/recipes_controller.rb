require 'open-uri'
require 'hangry'


class RecipesController < ApplicationController
  before_action :set_recipe, only: [ :show, :card, :edit, :update, :set_published_status, :set_dismissed_status, :god_show ]
  skip_before_action :authenticate_user!, only: [ :show, :card, :cart, :select_all, :index]
  before_action :authenticate_admin!, only: [:new, :import, :create, :import, :god_show, :manage]

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
    @query = params[:query].present?
    @recipe_list_item = RecipeListItem.new

    if @category.present?
      @recipes = @category.recipes
    elsif params[:pending].present?
      @recipes = Recipe.where(status: "pending")
    elsif @query.present?
      @recipes = Recipe.search(@query, fields: [:title])[0..49] if @query
    else
      @recipes = Recipe.where(status: "published").last(100)
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
    @recipe.status = "published"
    # generate_ingredients_tags(@recipe)
    @recipe.save
    @recipe.items.each{ |item| item.validate }
    # @recipe.upload_to_cloudinary
   redirect_back(fallback_location:"/")
  end

  def set_dismissed_status
    @recipe.status = "dismissed"
    @recipe.save
    # @recipe.items.each{ |item| item.unvalidate }
   redirect_back(fallback_location:"/")
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
    params[:list_id] ? @list = List.find(params[:list_id]) : @list = List.create(name: @recipe.title, user: current_user, status: "saved", sorted_by: "rayon") if @list.nil?

    params[:items] ? items = params[:items] : items = @recipe.items.pluck(:name)

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
    @recipe = Recipe.friendly.find(params[:id])
  end


  def recipe_params
    params.require(:recipe).permit(:title, :servings, :ingredients, :instructions, :tag_list, :origin, :status, :link, :image_url, :rating, recipe_list_ids: [], recipe_list_items_attributes:[:name, :recipe_list_id, :recipe_id])
  end

end
