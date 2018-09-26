class MetaRecipeItemsController < ApplicationController
  before_action :set_meta_recipe, only: [ :new, :create, :edit, :update ]
  before_action :set_meta_recipe_item, only: [ :edit, :update ]


  def new
    @meta_recipe_item = MetaRecipeItem.new
  end

  def create
    @meta_recipe_item = MetaRecipeItem.new(meta_recipe_items_params)
    @meta_recipe_item.meta_recipe = @meta_recipe
    if @meta_recipe_item.save
      redirect_to meta_recipe_path(@meta_recipe)
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    @meta_recipe_item.update(meta_recipe_items_params)
    redirect_to meta_recipe_path(@meta_recipe)
  end

private
  def set_meta_recipe
    @meta_recipe = MetaRecipe.find(params[:meta_recipe_id])
  end

  def set_meta_recipe_item
    @meta_recipe_item = MetaRecipeItem.find(params[:id])
  end

  def meta_recipe_items_params
    params.require(:meta_recipe_item).permit(:food_id, :meta_recipe, :ingredient, :name)
  end
end
