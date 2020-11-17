class CategoriesController < ApplicationController
  before_action :authenticate_admin!
  skip_before_action :authenticate_user!, only: [ :select, :unselect ]


  def show
    @category = Category.find(params[:id])
    @categories = @category.children.sort_by{|e| e.name.parameterize }
    @path = @category.path
  end

  def index
    @category = Category.new
    if params[:query].present?
      @categories = Category.where('LOWER(name) LIKE ?', "%#{params[:query].downcase}%")
    else
      @categories = Category.roots.sort_by{|e| e.name.parameterize }
    end
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

  def select
    @content = params[:c]
    @category = Category.get_match(@content)
    render "select.js.erb"
    ahoy.track "Select category", name: @content
  end

  def unselect
    @category = Category.find(params[:category_id])
    render "unselect.js.erb"
    ahoy.track "Unselect item", name: @category.name
  end

  def tree
    @categories = Category.roots
  end

  def fetch_similar
    @category = Category.find(params[:category_id]) if params[:category_id]
    render 'fetch_similar.js.erb'
    ahoy.track "Show category", category_id: @category.id, name: @category.name
  end

  private
  def set_category
    @category = category.find(params[:category_id])
  end

  def category_params
    params.require(:category).permit(:name, :category_type, :store_section_id, :food_group_id, :food_id, :level, :parent_id, :rating) ## Rails 4 strong params usage
  end
end
