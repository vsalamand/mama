class MetaRecipesController < ApplicationController
  before_action :set_meta_recipe, only: [ :show, :edit, :update ]

def new
  @meta_recipe = MetaRecipe.new
  @meta_recipe_list_item = @meta_recipe.meta_recipe_list_items.build
end

def create
  @meta_recipe = MetaRecipe.new(meta_recipe_params)
  binding.pry
  @meta_recipe.ingredients = @meta_recipe.get_topping_ingredient if @meta_recipe.ingredients.empty?
  if @meta_recipe.save
    redirect_to meta_recipe_path(@meta_recipe)
  else
    redirect_to new_meta_recipe_path
  end
end

private
  def set_meta_recipe
    @meta_recipe = MetaRecipe.find(params[:id])
  end

  # use collection_singular_ids "ids: []" to create multiple nested meta recipe list items
  def meta_recipe_params
    params.require(:meta_recipe).permit(:name, :servings, :ingredients, :instructions, :meta_type, meta_recipe_list_ids: [], meta_recipe_list_items_attributes:[:name, :meta_recipe_list_id, :meta_recipe_id])
  end
end
