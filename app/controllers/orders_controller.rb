class OrdersController < ApplicationController
  private
  def set_order
    @order = Order.find(params[:id])
  end

  def order_params
    params.require(:order).permit(:user_id, :cart_id, :order_type, :context)
  end
end
