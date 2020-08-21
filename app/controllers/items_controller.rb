class ItemsController < ApplicationController
  before_action :set_recipe, only: [ :new, :create, :edit, :update ]
  before_action :set_list_item, only: [ :edit, :update, :unvalidate, :validate ]
  before_action :set_item, only: [ :edit, :update ]
  skip_before_action :authenticate_user!, only: [:select, :unselect, :show, :complete, :uncomplete, :destroy, :create, :edit, :update, :edit_modal]


  def new
    @item = Item.new
    @recipe_id = Recipe.find(params[:recipe_id]).id if params[:recipe_id]
  end

  def create
    @item = Item.new(items_params)
    if params[:list_id]
      @list = List.friendly.find(params[:list_id])
      @item = @item.set
      @item.list = @list
      if @item.save
        @headername = @item.get_header_name
        render "create.js.erb"
        # redirect_to list_path(@list)
        ahoy.track "Create list item", name: @item.name
      else
        redirect_to list_path(@list)
      end
    elsif @item.recipe
      redirect_to god_show_recipe_path(@item.recipe)
    else
      render 'new'
    end
  end

  def edit_modal
    @list = List.find(params[:list_id])
    @item = Item.find(params[:item_id])
    render "edit_modal.js.erb"
  end

  def edit
    @next_item = Item.where(is_validated: false).last
    # @next_item = Item.recipe_items_to_validate.last if @next_item.nil?
  end

  def update

    if params[:list_id]
      completed_status = @item.is_completed
      store_section = @item.store_section_id
      new_store_section = items_params["store_section_id"].to_i

      @item.update(items_params)
      @item = @item.set
      @item.is_completed = completed_status
      # if user is updating store section specificaly
      if (new_store_section != store_section)
        @item.store_section_id = new_store_section
        @item.is_validated = false
      end
      @item.save
      @store_section_name = @item.get_store_section_name.downcase.parameterize(separator: '')

      render "update.js.erb"
      ahoy.track "Edit list item", name: @item.name

    elsif @item.recipe_id.present?
      @item.update(items_params)
      redirect_to god_show_recipe_path(@item.recipe_id)
    # elsif @item.list_item_id.present?
    #   redirect_to list_path(@item.list_item.list)
    else
      @item.update(items_params)
      redirect_to edit_item_path(@item)
    end
  end

  def complete
    @item = Item.find(params[:item_id])
    @list = @item.list
    @item.complete

    render "complete.js.erb"
    ahoy.track "complete list item", name: @item.name
  end

  def uncomplete
    @item = Item.find(params[:item_id])
    @list = @item.list
    @item.uncomplete

    render "uncomplete.js.erb"
    ahoy.track "Uncomplete list item", name: @item.name
  end

  def validate
    @item = Item.find(params[:item_id])
    @item.validate
    @next_item = Item.where(is_validated: false).last
    # @next_item = Item.recipe_items_to_validate.last if @next_item.nil?

    redirect_to edit_item_path(@next_item)
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
    @list = @item.list
    if @list
      @item.delete
      @store_section = @item.get_store_section_name.parameterize(separator: '')
      render "delete.js.erb"
      ahoy.track "Destroy list item", name: @item.name
    else
      @item.destroy
      redirect_to verify_items_path
    end
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
    if params[:query].present? && params[:food_id][:id].present?
      @food = Food.find(params[:food_id][:id])
      @results = Item.where('LOWER(trim(name)) LIKE ?', "%#{params[:query].downcase}%").where(food_id: @food.id)
    elsif params[:query].present?
      @results = Item.where('LOWER(trim(name)) LIKE ?', "%#{params[:query].downcase}%")
    elsif params[:food_id].present?
      @food = Food.find(params[:food_id])
      @results = Item.where(food_id: @food.id)
    elsif params[:category_id].present?
      @category = Category.find(params[:category_id])
      @results = Item.where(category_id: @category.id)
    elsif params[:is_labeled].present?
      @results = Item.where(food_id: nil).where(store_section_id: nil).where(recipe_id: nil)
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

  def select
    @item = Item.find(params[:item_id])
    render "select.js.erb"
    ahoy.track "Select item", name: @item.name
  end

  def unselect
    @item = Item.find(params[:item_id])
    render "unselect.js.erb"
    ahoy.track "Unselect item", name: @item.name
  end


  private
  def set_recipe
    @recipe = Recipe.friendly.find(params[:recipe_id]) if params[:recipe_id].present?
  end

  def set_list_item
    @list_item = ListItem.find(params[:list_item_id]) if params[:list_item_id].present?
  end

  def set_item
    @item = Item.find(params[:id])
  end

  def items_params
    params.require(:item).permit(:food_id, :recipe, :recipe_id, :category_id, :list, :list_item, :unit_id, :quantity, :name, :is_validated, :is_deleted, :is_completed, :is_non_food, :store_section_id) ## Rails 4 strong params usage
  end
end
