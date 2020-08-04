class CategoriesController < ApplicationController
  before_action :authenticate_admin!

  def show
    @category = Category.find(params[:id])
    @categories = @category.children.sort_by{|e| e.name.parameterize }
    @path = @category.path
  end

  def index
    @category = Category.new
    @categories = Category.roots.sort_by{|e| e.name.parameterize }
  end


  def new
    @category = Category.new
  end

  def create
    @category = Category.new(category_params)
    if @category.save
      redirect_to category_path(@category)
    else
      redirect_to new_category_path
    end
  end


  def edit
    @category = Category.find(params[:id])
  end

  def update
    @category = Category.find(params[:id])
    @category.update(category_params)
    redirect_to category_path(@category)
  end

  def destroy
    @category = Category.find(params[:id])
    @parent = @category.parent
    @category.destroy
    redirect_to category_path(@parent)
  end

  def tree
    @categories = Category.roots
  end

  private
  def set_category
    @category = category.find(params[:category_id])
  end

  def category_params
    params.require(:category).permit(:name, :category_type, :store_section_id, :food_id, :level, :parent_id) ## Rails 4 strong params usage
  end
end
