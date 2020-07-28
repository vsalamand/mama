class CategoriesController < ApplicationController
  before_action :authenticate_admin!

  def show
    @category = Category.find(params[:id])
    @categories = @category.children
    @root = @category.root if @category.root.present? && @category.root != @category && @category.root != @category.parent
    @parent = @category.parent if @category.parent.present?
    @children = @category.children if @category.children.present?
  end

  def index
    @category = Category.new
    @categories = Category.where(level: 0)
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

  def tree
    @categories = Category.where(level: 0)
  end

  private
  def set_category
    @category = category.find(params[:category_id])
  end

  def category_params
    params.require(:category).permit(:name, :category_type, :store_section_id, :level, :parent_id) ## Rails 4 strong params usage
  end
end
