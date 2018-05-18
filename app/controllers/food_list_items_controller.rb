class FoodListItemsController < ApplicationController

  private
  def food_list_item_params
    params.require(:food_list_item).permit(:food_id, :food_list_id, :checklist_id, :name)
  end
end
