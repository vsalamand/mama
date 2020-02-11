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
      redirect_to god_show_recipe_path(@recipe) if params[:recipe_id].present?
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    @item.update(items_params)
    redirect_to god_show_recipe_path(@recipe) if params[:recipe_id].present?
    redirect_to list_path(@list_item.list) if params[:list_item_id].present?
  end

  def validate
    item = @list_item.items.last
    item.validate
    render "validate.js.erb"
  end

  def unvalidate
    @list = @list_item.list
    @item = @list_item.items.last
    @item.unvalidate
    mail = ReportMailer.report_item(@item)
    mail.deliver_now
    render "unvalidate.js.erb"
  end

  def destroy
    @item = Item.find(params[:id])
    @list = @item.list_item.list
    @item.destroy
    redirect_to list_path(@list)
  end

  def add_to_list
    @recipe = Recipe.find(params[:recipe_id])
    @item = Item.find(params[:item_id])
    params[:list_id] ? @list = List.find(params[:list_id]) : @list = List.create(name: @recipe.title, user: current_user) if @list.nil?

    ListItem.add_to_list(@item.name, @list)

    respond_to do |format|
      format.js { flash.now[:notice] = "Ajouté à la liste !" }
    end
  end

  def index
    food_id = params[:food].present? ? params[:food]['id'] : nil

    if food_id.present?
      @food = Food.find(food_id)
      @results = Item.where(food_id: @food.id)
    end

  end

  def edit_multiple
    @items = Item.find(params[:item_ids])
  end

  def update_multiple
    @items = Item.find(params[:item_ids])
    @items.each{ |product| product.update(items_params)}
    redirect_to items_path
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
    params.require(:item).permit(:food_id, :recipe, :list_item, :unit_id, :quantity, :name, :is_validated) ## Rails 4 strong params usage
  end
end
