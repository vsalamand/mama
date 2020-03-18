class RecipeListsController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :authenticate_admin!, only: [:index ]

  def index
    @recipe_lists = RecipeList.where(recipe_list_type: "curated")
    @recipe_list = RecipeList.new
    # @recipe_lists = current_user.recipe_lists.where(status: "saved")
  end

  def show
    @recipe_list = RecipeList.find(params[:id])
    # @recipe_list.recipe_list_items.build
    # @checklist = Checklist.get_checklist(@recipe_list.foods)
  end

  def new
    @recipe_list = RecipeList.new
  end

  def create
    @recipe_list = RecipeList.new(recipe_list_params)
    if @recipe_list.save
      redirect_to recipe_lists_path if @recipe_list.recipe_list_type == "curated"
      redirect_to explore_recipe_list_path(@recipe_list) if @recipe_list.recipe_list_type == "personal" && @recipe_list.status == "opened"
      redirect_to recipe_list_path(@recipe_list) if @recipe_list.recipe_list_type == "personal" && @recipe_list.status == "saved"
    else
      redirect_to new_recipe_list_path
    end
  end

  def edit
    @recipe_list = RecipeList.find(params[:id])
  end

  def update
    @recipe_list = RecipeList.find(params[:id])
    @recipe_list.update(recipe_list_params)
    # @recipe_list.get_description
    redirect_to recipe_list_path(@recipe_list) if @recipe_list.recipe_list_type == "personal"
    redirect_to recipe_lists_path if @recipe_list.recipe_list_type == "curated"
  end

  def explore
    @recipe_list = RecipeList.find(params[:id])
    @categories = Recommendation.where(is_active: true).last
  end

  def search
    @recipe_list = RecipeList.find(params[:id])
    @query = params[:query].present? ? params[:query] : nil

    @recipes = Recipe.search(@query, fields: [:title, :ingredients, :tags, :categories])[0..29] if @query

    respond_to do |format|
      format.html
      format.js
    end
  end

  def category
    @recipe_list = RecipeList.find(params[:id])
    @category = RecommendationItem.find(params[:recommendation_item_id])
    @recipes = @category.recipe_list.recipe_list_items.map{ |rli| rli.recipe }
  end

  def add_recipe
    @recipe_list = RecipeList.find(params[:id])
    recipe = Recipe.find(params[:id])
  end

  def destroy
    @recipe_list = RecipeList.find(params[:id])
    @recipe_list.destroy
    flash[:notice] = 'Le menu a été supprimé.'
    redirect_to root_path if @recipe_list.recipe_list_type == "personal"
    redirect_to recipe_lists_path if @recipe_list.recipe_list_type == "curated"
  end

  def add_to_list
    @recipe_list = RecipeList.find(params[:id])
    @recipe_list.is_saved

    params[:list_id] ? @list = List.find(params[:list_id]) : @list = List.create(name: "Liste de courses - #{@recipe_list.name}", user: current_user, status: "opened") if @list.nil?
    items = params[:items]

    ListItem.add_menu_to_list(items, @list)

    render 'add_to_list.js.erb'
  end

  def fetch_recipes
    @recipe_list = RecipeList.find(params[:id])
    @recipes = Recipe.where(status:'published')
                      .order(created_at: :desc)
                      .limit(780)
                      .shuffle[0..9]
                      # .where(id: [1406..1577])
    render 'fetch_recipes.js.erb'
  end

  def get_size
    @recipe_list = RecipeList.find(params[:id])
    @size = @recipe_list.recipes.size

    render json: @size
  end

  def clean
    @recipe_list = RecipeList.find(params[:id])
    @recipe_list.clean

    redirect_to root_path
  end

  private
  def recipe_list_params
    params.require(:recipe_list).permit(:id, :name, :user_id, :diet_id, :description, :status, :tag_list, :recipe_list_type, recipe_ids: [])
  end
end
