class ListItemsController < ApplicationController
  before_action :set_list_item, only: [ :show, :edit, :update ]
  before_action :set_list, only: [ :show, :create, :edit, :update ]
  skip_before_action :authenticate_user!, only: [:show, :complete, :uncomplete, :destroy, :create, :edit, :update, :edit_modal]

  def new
    @list_item = ListItem.new
  end

  def create
    @list = List.friendly.find(params[:list_id])
    @list_item = ListItem.new(list_item_params)
    @list_item.list = @list

    if @list_item.save
      store_section = @list_item.store_section
      store_section.present? ? @store_section_name = store_section.name.parameterize(separator: '') : @store_section_name = "autres"
      # @list_item.create_or_copy_item

      respond_to do |format|
        format.html { redirect_to list_path(@list) }
        format.js  # <-- will render `app/views/list_items/create.js.erb`
      end
      ahoy.track "Create list item", name: @list_item.name

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
    @list = @list_item.list
    @list_item.update_item(item) if item.present?
    # if list item contains an item, then update it
    if @list_item.save
      render "update.js.erb"
      ahoy.track "Edit list item", name: @list_item.name
    end
  end

  def destroy
    @list_item = ListItem.find(params[:id])
    @list = @list_item.list
    ahoy.track "Destroy list item", name: @list_item.name

    @list_item.delete
    @store_section = @list_item.get_store_section.parameterize(separator: '')

    render "delete.js.erb"
  end

  def complete
    @list_item = ListItem.find(params[:list_item_id])
    @list = @list_item.list
    @list_item.complete

    render "complete.js.erb"
    ahoy.track "complete list item", name: @list_item.name
  end

  def uncomplete
    @list_item = ListItem.find(params[:list_item_id])
    @list = @list_item.list
    @list_item.uncomplete

    render "uncomplete.js.erb"
    ahoy.track "Uncomplete list item", name: @list_item.name
  end

  def sort
    params[:list_item].each_with_index do |id, index|
      ListItem.where(id: id).update_all(position: index + 1)
    end

    head :ok
  end

  def edit_modal
    @list = List.find(params[:list_id])
    @list_item = ListItem.find(params[:list_item_id])
    render "edit_modal.js.erb"
  end

  private

  def list_item_params
    params.require(:list_item).permit(:name, :list_id, :deleted, :is_completed, :position, items_attributes:[:id, :name, :quantity, :food_id, :unit_id, :list_item_id, :is_validated, :recipe_id])
  end

  def set_list_item
    @list_item = ListItem.find(params[:id])
  end

  def set_list
    @list = List.friendly.find(params[:list_id])
  end
end
