class IngredientsController < ApplicationController

  private
  def ingredient_params
    params.require(:ingredient).permit(:name, :tag_list) ## Rails 4 strong params usage
  end
end
