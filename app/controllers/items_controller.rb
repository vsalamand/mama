class ItemsController < ApplicationController
  before_action :set_recipe, only: [ :new, :create, :edit, :update ]
  before_action :set_list_item, only: [ :edit, :update, :unvalidate, :validate ]
  before_action :set_item, only: [ :edit, :update ]

  def new
    @item = Item.new
  end

  def create
    @item = Item.new(items_params)
    @item.recipe = @recipe
    if @item.save
      redirect_to recipe_path(@recipe)
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    @item.update(items_params)
    redirect_to recipe_path(@recipe) if params[:recipe_id].present?
    redirect_to list_path(@list_item.list) if params[:list_item_id].present?
  end

  def validate
    item = @list_item.items.last
    item.validate
  end

  def unvalidate
    @list = @list_item.list
    item = @list_item.items.last
    item.unvalidate
    render "unvalidate.js.erb"
  end

  private
  def set_recipe
    @recipe = Recipe.find(params[:recipe_id]) if params[:recipe_id].present?
  end

  def set_list_item
    @list_item = ListItem.find(params[:list_item_id]) if params[:list_item_id].present?
  end

  def set_item
    @item = Item.find(params[:id])
  end

  def items_params
    params.require(:item).permit(:food_id, :recipe, :list_item, :unit_id, :quantity, :name) ## Rails 4 strong params usage
  end
end
