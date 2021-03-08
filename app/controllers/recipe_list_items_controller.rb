class RecipeListItemsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:select, :unselect]


  def destroy
    @recipe_list_item = RecipeListItem.find(params[:id])
    @recipe_list = @recipe_list_item.recipe_list
    @recipe = @recipe_list_item.recipe

    @recipe_list_item.destroy

    render 'delete.js.erb'
    ahoy.track "Remove recipe", request.path_parameters
  end

  def select
    @recipe_list_item = RecipeListItem.find(params[:id])
    render 'select.js.erb'
  end

  def unselect
    @recipe_list_item = RecipeListItem.find(params[:id])
    render 'unselect.js.erb'
  end

  private
  def recipe_list_item_params
    params.require(:recipe_list_item).permit(:recipe_id, :recipe_list_id, :list_id, :recommendation_id, :position, :name)
  end
end
