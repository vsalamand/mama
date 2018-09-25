class MetaRecipeListsController < ApplicationController

  def new
    @meta_recipe_list = MetaRecipeList.new
    @meta_recipe_list.meta_recipe_list_items.build
  end

  def create
    @meta_recipe_list = MetaRecipeList.new(meta_recipe_list_params)
    @meta_recipe_list.name = @meta_recipe_list.get_title
    if @meta_recipe_list.save
      redirect_to confirmation_path
    else
      redirect_to new_meta_recipe_list_path
    end
  end

  private
  def meta_recipe_list_params
    params.require(:meta_recipe_list).permit(:name, :recipe_id, meta_recipe_list_items_attributes:[:name, :meta_recipe_list_id, :meta_recipe_id])
  end

end
