class FoodListItemsController < ApplicationController
  before_action :set_food_list_item, only: [:destroy]
  skip_before_action :authenticate_user!, only: [:crecreate_foodlist_itemate, :destroy]


  def create_foodlist_item
    food = Food.find(params[:format])
    @foodlist = FoodList.find(params[:id])

    current_item = @foodlist.food_list_items.find_by(food_id: food.id)

    unless current_item
      FoodListItem.create(name: food.name, food_id: food.id, food_list_id: @foodlist.id)
       redirect_to :back
    else
       redirect_to :back
    end
  end

  def destroy
    @foodlist = FoodList.find(params[:food_list_id])
    @foodlist_item.destroy
    redirect_to :back
  end

  private
  def set_food_list_item
    @foodlist_item = FoodListItem.find(params[:id])
  end

  def food_list_item_params
    params.require(:food_list_item).permit(:food_id, :food_list_id, :checklist_id, :name)
  end
end
