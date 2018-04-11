class RecipeListItemsController < ApplicationController

  private
  def recipe_list_item_params
    params.require(:recipe_list_item).permit(:recipe_id, :recipe_list_id, :position, :name)
  end
end
