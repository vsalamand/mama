class ListItemsController < ApplicationController
  before_action :set_list_item, only: [ :show, :edit, :update ]
  before_action :set_list, only: [ :show, :create, :edit, :update ]


  def create
    @list = List.find(params[:list_id])
    @list_item = ListItem.new(list_item_params)
    @list_item.list = @list
    # verify if validated item with same input already exists
    valid_item = Item.find_by(name: @list_item.name, is_validated: true)

    if @list_item.save
      # render view
      respond_to do |format|
        format.html { redirect_to list_path(@list) }
        format.js  # <-- will render `app/views/list_items/create.js.erb`
      end
      # create new item or copy item if from recipe
      Thread.new do
        if valid_item.present?
          Item.create(quantity: valid_item.quantity, unit: valid_item.unit, food: valid_item.food, list_item: @list_item, name: valid_item.name, is_validated: valid_item.is_validated)
        else
          Item.create_list_item(@list_item)
       end
      end
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
    @list_item.name = list_item_params[:items_attributes]["0"][:name]
    @list_item.save
    redirect_to list_path(@list)
  end

  def destroy
    @list_item = ListItem.find(params[:id])
    @list_item.delete
    render "delete.js.erb"
  end


  private

  def list_item_params
    params.require(:list_item).permit(:name, :list_id, :deleted, items_attributes:[:id, :name, :quantity, :food_id, :unit_id, :list_item_id, :recipe_id])
  end

  def set_list_item
    @list_item = ListItem.find(params[:id])
  end

  def set_list
    @list = List.find(params[:list_id])
  end
end