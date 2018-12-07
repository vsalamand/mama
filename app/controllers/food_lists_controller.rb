class FoodListsController < ApplicationController
  before_action :set_food_list, only: [ :show ]

  def show
    @foods = @foodlist.foods.sort_by { |food| food.recipes.where(status: "published").count }.reverse
    @seasonal_foods = Food.select_seasonal_food(@foods)
  end

  private
  def food_list_params
    params.require(:food_list).permit(:name, :user_id, :diet_id, :description, :food_list_type)
  end

  def set_food_list
    @foodlist = FoodList.find(params[:id])
  end
end
