class ListsController < ApplicationController
  before_action :set_list, only: [ :show ]
  skip_before_action :authenticate_user!, only: [:show]
  before_action :authenticate_admin!, only: [:index, :new, :create]

  def show
    @list = List.find(params[:id])
    @list_item = ListItem.new
    @list_items = @list.list_items.not_deleted
  end

  def explore
    @list = List.find(params[:list_id])
    @list_item = ListItem.new
    @recipes = RecipeList.where(recipe_list_type: "curated").last.recipes
  end

  private
  def list_params
    params.require(:list).permit(:id, :name, :user_id)
  end

  def set_list
    @list = List.find(params[:id])
  end
end
