class FoodListsController < ApplicationController

  private
  def food_list_params
    params.require(:food_list).permit(:name, :user_id, :description, :food_list_type)
  end
end
