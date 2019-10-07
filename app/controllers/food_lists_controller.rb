class FoodListsController < ApplicationController
  before_action :set_food_list, only: [ :show, :edit, :update, :add, :destroy_item, :fetch_recipes ]
  skip_before_action :authenticate_user!, only: [:create, :add, :new, :show]
  protect_from_forgery except: :add

  def show
    @foodlist.food_list_items.build
  end

  def new
    @foodlist = FoodList.new
  end

  def create
    @foodlist = FoodList.new(food_list_params)
    @foodlist.name = "Liste de courses" + "#{(current_user.food_lists.where(food_list_type: "grocery_list").size + 1) if user_signed_in? }"
    @foodlist.user = current_user
    @foodlist.food_list_type = "grocery_list"
    if @foodlist.save
      redirect_to add_food_list_path(@foodlist)
    else
      redirect_back(fallback_location:"/")
    end
  end

  def edit
    @similar_food = @foodlist.get_similar_food
    @seasonal_produce = @foodlist.get_seasonal_produce
  end

  def update
    @foodlist.update(food_list_params)
    redirect_to food_list_path(@foodlist)
  end

  def index
    @foodlist = FoodList.new
    @foodlists = current_user.food_lists.where(food_list_type: "grocery_list")
  end

  def add
    @promo_foods = @foodlist.get_promo_foods
    # @similar_food = @foodlist.get_similar_food
    @search = Food.search(params[:query], limit: 10) if params[:query]

    respond_to do |format|
      format.html { }
      format.js {}
    end

  end

  def fetch_recipes
    @recommended_recipes = RecipeList.where(recipe_list_type: "curated").last.recipes
    render 'fetch_recipes.js.erb'
  end

  # def show
  #   @foods = @foodlist.foods.sort_by { |food| food.recipes.where(status: "published").count }.reverse
  #   @seasonal_foods = Food.select_seasonal_food(@foods)
  # end

  private
  def food_list_params
    params.require(:food_list).permit(:id, :name, :user_id, :diet_id, :description, :food_list_type, food_ids: [])
  end

  def set_food_list
    @foodlist = FoodList.find(params[:id])
  end
end
