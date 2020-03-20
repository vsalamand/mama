class OrdersController < ApplicationController

  def show
    @order = Order.find(params[:id])
    @cart = @order.cart
  end

  private
  def set_order
    @order = Order.find(params[:id])
  end

  def order_params
    params.require(:order).permit(:user_id, :cart_id, :order_type, :context)
  end
end
