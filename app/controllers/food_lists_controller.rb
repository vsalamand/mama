class FoodListsController < ApplicationController
  before_action :set_food_list, only: [ :show ]

  private
  def food_list_params
    params.require(:food_list).permit(:name, :user_id, :diet_id, :description, :food_list_type)
  end

  def set_food_list
    @foodlist = FoodList.find(params[:id])
  end
end
