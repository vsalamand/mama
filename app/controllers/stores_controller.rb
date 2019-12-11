class StoresController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :show, :catalog ]

  def show
    @store = Store.find(params[:id])
    @shelters = @store.get_main_shelter_list
  end

  def catalog
    @store = Store.find(params[:store_id])
    @food = Food.find(params[:food_id])
    @store_items = @food.store_items.where(store: @store)
  end

  private
  def stores_params
    params.require(:product).permit(:id, :name, :store_type, :merchant_id)
  end
end
