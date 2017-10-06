class ItemsController < ApplicationController

  private
  def ingredient_params
    params.require(:item).permit(:ingredient, :recipe, :unit, :quantity, :recipe_ingredient) ## Rails 4 strong params usage
  end
end
