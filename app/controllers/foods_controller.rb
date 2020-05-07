class FoodsController < ApplicationController
  before_action :set_food, only: [ :show, :edit, :update ]
  before_action :authenticate_admin!, only: [:new, :create, :edit, :update, :show ]

  def index
    @foods = Food.all
  end

  def new
    @food = Food.new
  end

  def create
    @food = Food.new(food_params)
    if @food.save
      redirect_to food_path(@food)
    else
      redirect_to new_food_path
    end
  end

  def show
    @food = Food.find(params[:id])
  end

  def edit
  end

  def update
    @food.update(food_params)
    redirect_to food_path(@food)
  end

  private
  def set_food
   @food = Food.find(params[:id])
  end

  def food_params
    params.require(:food).permit(:name, :availability, :category_id, :store_section_id, :tag_list, food_list_ids: [], food_list_items_attributes:[:name, :food_list_id, :food_id]) ## Rails 4 strong params usage
  end
end
