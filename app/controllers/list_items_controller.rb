class ListItemsController < ApplicationController


  def create
    @list = List.find(params[:list_id])
    @list_item = ListItem.new(list_item_params)
    @list_item.list = @list
    if @list_item.save
      # render view
      respond_to do |format|
        format.html { redirect_to list_path(@list) }
        format.js  # <-- will render `app/views/list_items/create.js.erb`
      end
      # create item
      Thread.new  do
        Item.create_list_item(@list_item)
      end
    else
      respond_to do |format|
        format.html { render 'lists/show' }
        format.js  # <-- idem
      end
    end
  end

  def destroy
    @list_item = ListItem.find(params[:id])
    @list_item.delete
    render "delete.js.erb"
  end

  private

  def list_item_params
    params.require(:list_item).permit(:name, :list_id, :deleted)
  end
end
