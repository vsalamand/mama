class FoodsController < ApplicationController
  before_action :set_food, only: [ :show, :edit, :update ]
  before_action :authenticate_admin!, only: [:new, :create, :edit, :update, :show ]

  def index
    @categories = Category.all.where.not(ancestry: nil)
    @store_sections = StoreSection.all

    @category = Category.find(params[:category_id]) if params[:category_id].present?
    @store_section = StoreSection.find(params[:section_id]) if params[:section_id].present?
    if @category.present?
      @foods = @category.foods
    elsif @store_section.present?
      @foods = @store_section.foods
    else
      @foods = Food.all
    end
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
