class UnitsController < ApplicationController

  private
  def food_params
    params.require(:food).permit(:name) ## Rails 4 strong params usage
  end
end
