class RecipeListItemsController < ApplicationController

  def destroy
    @recipe_list_item = RecipeListItem.find(params[:id])
    @recipe_list = @recipe_list_item.recipe_list
    @recipe = @recipe_list_item.recipe

    @recipe_list_item.destroy

    render 'delete.js.erb'
    ahoy.track "Remove recipe", request.path_parameters
  end

  private
  def recipe_list_item_params
    params.require(:recipe_list_item).permit(:recipe_id, :recipe_list_id, :recommendation_id, :position, :name)
  end
end
