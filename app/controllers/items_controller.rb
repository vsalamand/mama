class ItemsController < ApplicationController

  def new
    @recipe = Recipe.find(params[:recipe_id])
    @item = Item.new
  end

  def create
    @recipe = Recipe.find(params[:recipe_id])
    @item = Item.new(items_params)
    @item.recipe = @recipe
   if @item.save
      redirect_to item_recipe_path(@recipe, @item)
    else
      render 'new'
    end
  end

  private
  def items_params
    params.require(:item).permit(:ingredient, :recipe, :unit, :quantity, :recipe_ingredient) ## Rails 4 strong params usage
  end
end
