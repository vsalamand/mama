class OrdersController < ApplicationController

  def show
    @order = Order.find(params[:id])
    @cart = @order.cart
    ahoy.track "Order", request.path_parameters
  end

  private
  def set_order
    @order = Order.find(params[:id])
  end

  def order_params
    params.require(:order).permit(:user_id, :cart_id, :order_type, :context)
  end
end
