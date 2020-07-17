class StoreSectionItemsController < ApplicationController
  before_action :authenticate_admin!

  def edit
    @store = Store.find(params[:store_id])
    @store_section_item = StoreSectionItem.find(params[:id])
  end

  def update
    @store = Store.find(params[:store_id])
    @store_section_item = StoreSectionItem.find(params[:id])
    @store_section_item.update(store_section_items_params)
    redirect_to store_store_section_path(@store, store_section_item_id: @store_section_item.id)
  end


  private
  def store_section_items_params
    params.require(:store_section_item).permit(:id, :name, :breadcrumb, :store_id, :store_section_id, :level)
  end
end
