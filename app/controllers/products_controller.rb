class ProductsController < ApplicationController

  def report
    product = StoreItem.find(params[:format]).product
    product.report
    if params[:cart_id].present?
      @cart = Cart.find(params[:cart_id])
      @cart_item = CartItem.find(params[:cart_item_id])
      @food = StoreItem.find(params[:format]).food
      render "cart_report.js.erb"
    elsif params[:list_id].present?
      @list = List.find(params[:list_id])
      @list_item = ListItem.find(params[:list_item_id])
      @food = StoreItem.find(params[:format]).food
      render "list_report.js.erb"
    end
    ReportMailer.report_product(product)
  end

  def search
    @food = Food.find(params[:format])
    if params[:cart_id].present?
      @cart = Cart.find(params[:cart_id])
      @cart_item = CartItem.find(params[:cart_item_id])
      @item = @cart_item.item
      render "cart_search.js.erb"
    elsif params[:list_id].present?
      @list = List.find(params[:list_id])
      @list_item = ListItem.find(params[:list_item_id])
      @item = @list_item.items.last
      render "list_search.js.erb"
    end
  end

  private
  def products_params
    params.require(:product).permit(:id, :food_id, :ean, :name, :quantity, :unit_id, :brand, :origin, :is_frozen, :is_reported)
  end
end
