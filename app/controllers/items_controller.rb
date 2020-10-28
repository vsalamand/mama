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
      @saved_item = @item.find_saved_item(@list)
      # if new item name is similar to saved products => use uncomplete method
      if @saved_item.present?
        @item = @saved_item
        @list = @item.list
        @new_item = @item.dup
        @new_item.uncomplete
        @item.delete

        @headername = @new_item.get_header_name

        render "uncomplete.js.erb"
        ahoy.track "Create list item", name: @item.name, context: "saved products"
      # else just create new item
      else
        @item = @item.set
        @item.list = @list
        if @item.save
          @headername = @item.get_header_name
          render "create.js.erb"
          @list.unsave_items(@item)
          # redirect_to list_path(@list)
          ahoy.track "Create list item", name: @item.name, context: "#{params[:c]}"
        else
          redirect_to list_path(@list)
        end
      end

    elsif params[:recipe_id]
      @item = @item.set
      @item.recipe = Recipe.friendly.find(params[:recipe_id])
      @item.save
      redirect_to recipe_path(@item.recipe)
    else
      render 'new'
    end
  end

  def show
    @item = Item.find(params[:id])
    @recipes = Recipe.where(status: "published").search(@item.category.name, fields: [:title, :ingredients])[0..19] if @item.category.present?

    ahoy.track "Show item", name: @item.name
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

      @item.is_validated = false
      @item.update(items_params)
      @item = @item.set

      # if user is updating store section specificaly
      store_section_id = @item.store_section_id.to_i
      new_store_section_id = items_params["store_section_id"].to_i
      if (new_store_section_id != store_section_id)
        new_store_section_id > 0 ? @item.store_section_id = new_store_section_id : @item.store_section_id = nil
        @item.is_validated = false
      end

      @item.save
      @headername = @item.get_header_name

      respond_to do |format|
        format.html { redirect_to list_path(@item.list) }
        format.js { render 'update.js.erb' }
      end

      ahoy.track "Edit list item", name: @item.name

    elsif @item.recipe_id.present?
      @item.update(items_params)
      redirect_to pending_path
    # elsif @item.list_item_id.present?
    #   redirect_to list_path(@item.list_item.list)
    else
      @item.update(items_params)
      @item = @item.set
      redirect_to edit_item_path(@item)
    end
  end

  def complete
    @item = Item.find(params[:item_id])
    @list = @item.list
    @list.unsave_items(@item)
    @item.complete

    render "complete.js.erb"
    ahoy.track "complete list item", name: @item.name
  end

  def uncomplete
    @item = Item.find(params[:item_id])
    @list = @item.list
    @new_item = @item.dup
    @new_item.uncomplete
    @item.delete

    @headername = @new_item.get_header_name

    render "uncomplete.js.erb"
    ahoy.track "Create list item", name: @item.name, context: "saved products"
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
      @headername = @item.get_header_name
      render "delete.js.erb"
      ahoy.track "Destroy list item", name: @item.name
    else
      @item.destroy
      redirect_back(fallback_location:"/")
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
    @servings_delta = params[:s].to_f
    render "select.js.erb"
    ahoy.track "Select item", name: @item.name
  end

  def unselect
    @item = Item.find(params[:item_id])
    @servings_delta = params[:s].to_f
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
