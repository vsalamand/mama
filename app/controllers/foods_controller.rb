class FoodsController < ApplicationController

  private
  def food_params
    params.require(:food).permit(:name, :availability, :category_id, :tag_list, food_list_ids: [], food_list_items_attributes:[:name, :food_list_id, :food_id]) ## Rails 4 strong params usage
  end
end
