class FoodsController < ApplicationController

  private
  def food_params
    params.require(:food).permit(:name, :tag_list) ## Rails 4 strong params usage
  end
end
