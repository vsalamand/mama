class CartsController < ApplicationController
  before_action :set_cart, only: [ :show ]

  private
  def set_cart
    @cart = Cart.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    @cart = Cart.create
  end

  def carts_params
    params.require(:cart).permit(:user_id)
  end
end
