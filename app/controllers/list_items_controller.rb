class ListItemsController < ApplicationController
  before_action :set_list_item, only: [ :show, :edit, :update ]
  before_action :set_list, only: [ :show, :create, :edit, :update ]
  skip_before_action :authenticate_user!, only: [:show, :complete, :uncomplete, :destroy, :create, :edit, :update]

  def new
    @list_item = ListItem.new
  end

  def create
    @list = List.find(params[:list_id])
    @list_item = ListItem.new(list_item_params)
    @list_item.list = @list

    if @list_item.save
      @list_item.create_or_copy_item
      @store_section = @list_item.get_store_section

      # render view
      respond_to do |format|
        format.html { redirect_to list_path(@list) }
        format.js  # <-- will render `app/views/list_items/create.js.erb`
      end
      ahoy.track "Create list item", request.path_parameters

    else
      respond_to do |format|
        format.html { render 'lists/show' }
        format.js  # <-- idem
      end
    end
  end

  def edit
  end

  def update
    @list_item.update(list_item_params)
    item = @list_item.get_item
    @list_item.update_item(item) if item.present?
    # if list item contains an item, then update it
    if @list_item.save
      render "update.js.erb"
    end
  end

  def destroy
    @list_item = ListItem.find(params[:id])
    @list_item.delete
    @store_section = @list_item.get_store_section

    render "delete.js.erb"
    ahoy.track "Destroy list item", request.path_parameters
  end

  def complete
    @list_item = ListItem.find(params[:list_item_id])
    @list_item.complete
    @store_section = @list_item.get_store_section

    render "complete.js.erb"
    ahoy.track "complete list item", request.path_parameters
  end

  def uncomplete
    @list_item = ListItem.find(params[:list_item_id])
    @list_item.uncomplete
    @store_section = @list_item.get_store_section

    render "uncomplete.js.erb"
    ahoy.track "Uncomplete list item", request.path_parameters
  end

  def sort
    params[:list_item].each_with_index do |id, index|
      ListItem.where(id: id).update_all(position: index + 1)
    end

    head :ok
  end

  private

  def list_item_params
    params.require(:list_item).permit(:name, :list_id, :deleted, :is_completed, :position, items_attributes:[:id, :name, :quantity, :food_id, :unit_id, :list_item_id, :is_validated, :recipe_id])
  end

  def set_list_item
    @list_item = ListItem.find(params[:id])
  end

  def set_list
    @list = List.find(params[:list_id])
  end
end
