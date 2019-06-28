class MetaRecipeListsController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :show, :new, :create ]

  def show
    @meta_recipe_list = MetaRecipeList.find(params[:id])
  end

  def new
    @meta_recipe_list = MetaRecipeList.new
    @meta_recipe_list.meta_recipe_list_items.build
  end

  def create
    # clean params ids when mixing MRL & MR to create new MRL
    parameters = clean_params
    @meta_recipe_list = MetaRecipeList.new(parameters)
    @meta_recipe_list.name = @meta_recipe_list.get_title
    @meta_recipe_list.list_type = "recipe"
    if @meta_recipe_list.save
      redirect_to pending_path
      # redirect_to recipe_path(@meta_recipe_list.recipe, format: :pdf)
      # redirect_to card_recipe_url(@meta_recipe_list.recipe)
      # redirect_to meta_recipe_list_path(@meta_recipe_list)
      # redirect_to :back
    else
      # redirect to existing meta recipe list
      # redirect_to recipe_path(@meta_recipe_list.find_by_meta_recipe_ids(meta_recipe_list_params[:meta_recipe_ids]).recipe, format: :pdf)
      redirect_to recipe_path(@meta_recipe_list.find_by_meta_recipe_ids(parameters[:meta_recipe_ids]).recipe, format: :pdf)
    end
  end

  def pending
    @meta_recipe_lists = MetaRecipeList.where(recipe_id: [nil, ""])
  end

  def pool
    @meta_recipe_list = MetaRecipeList.find(params[:meta_recipe_list_id])
  end

  def create_recipe
    @meta_recipe_list = MetaRecipeList.find(params[:id])
    @meta_recipe_list.create_recipe
    redirect_to meta_recipe_list_path(@meta_recipe_list)
  end

  private
  # use collection_singular_ids "ids: []" to create nested meta recipe list items through meta recipes in List creatin form
  def meta_recipe_list_params
    params.require(:meta_recipe_list).permit(:name, :link, :author, :id, :recipe_id, meta_recipe_ids: [])
  end

  # get all meta recipe ids during MRL creation when mixing MRL + MR
  def clean_params
    parameters = Hash.new
    unless params[:meta_recipe_list][:id].nil?
      # get extra meta recipe ids from MRL
      extra_ids = MetaRecipeList.find(params[:meta_recipe_list][:id].reject(&:empty?).first).meta_recipe_ids.reverse.map(&:to_s)
      # merge all meta recipe ids into params
      parameters[:meta_recipe_ids] = extra_ids + meta_recipe_list_params[:meta_recipe_ids]
    else
      parameters[:meta_recipe_ids] = meta_recipe_list_params[:meta_recipe_ids]
    end
    parameters[:link] = meta_recipe_list_params[:link]
    parameters[:author] = meta_recipe_list_params[:author]
    return parameters
  end

end
