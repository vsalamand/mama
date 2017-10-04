class UnitsController < ApplicationController

  private
  def ingredient_params
    params.require(:ingredient).permit(:name) ## Rails 4 strong params usage
  end
end
