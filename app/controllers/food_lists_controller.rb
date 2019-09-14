class FoodListsController < ApplicationController
  before_action :set_food_list, only: [ :show, :edit, :update, :add, :destroy_item ]

  def show
    @foodlist.food_list_items.build
  end

  def new
    @foodlist = FoodList.new
  end

  def create
    @foodlist = FoodList.new(food_list_params)
    @foodlist.name = "Liste de courses (#{Date.today.strftime('%d %m %Y')})"
    @foodlist.user = current_user
    @foodlist.food_list_type = "grocery_list"
    if @foodlist.save
      redirect_to food_list_path(@foodlist)
    else
      redirect_to new_food_list_path
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
    @foodlists = current_user.food_lists.where(food_list_type: "grocery_list")
  end

  def add
    query = params[:query].present? ? params[:query] : nil
    @results = if query
      Food.search(query, fields: [:name])[0..99]
    end
    @similar_food = @foodlist.get_similar_food
    @seasonal_produce = @foodlist.get_seasonal_produce - @foodlist.foods
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
