class ProductsController < ApplicationController

  def report
    product = Product.find(params[:format])
    product.report
    @cart = Cart.find(params[:cart_id])
    @cart_item = CartItem.find(params[:cart_item_id])
    @item = @cart_item.item
    render "report.js.erb"
  end

  private
  def products_params
    params.require(:product).permit(:id, :food_id, :ean, :name, :quantity, :unit_id, :brand, :origin, :is_frozen, :is_reported)
  end
end
