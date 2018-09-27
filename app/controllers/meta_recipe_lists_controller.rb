class MetaRecipeListsController < ApplicationController

  def show
    @meta_recipe_list = MetaRecipeList.find(params[:id])
  end

  def new
    @meta_recipe_list = MetaRecipeList.new
    @meta_recipe_list.meta_recipe_list_items.build
  end

  def create
    @meta_recipe_list = MetaRecipeList.new(meta_recipe_list_params)
    @meta_recipe_list.name = @meta_recipe_list.get_title
    if @meta_recipe_list.save
      redirect_to meta_recipe_list_path(@meta_recipe_list)
    else
      redirect_to new_meta_recipe_list_path
    end
  end

  def pending
    @meta_recipe_lists = MetaRecipeList.where(recipe_id: [nil, ""])
  end

  def create_recipe
    @meta_recipe_list = MetaRecipeList.find(params[:id])
    @meta_recipe_list.create_recipe
    redirect_to meta_recipe_list_path(@meta_recipe_list)
  end

  private
  def meta_recipe_list_params
    params.require(:meta_recipe_list).permit(:name, :recipe_id, meta_recipe_list_items_attributes:[:name, :meta_recipe_list_id, :meta_recipe_id])
  end

end