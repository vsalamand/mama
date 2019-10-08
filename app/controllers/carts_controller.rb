class CartsController < ApplicationController

  def show
    user = current_user
    @cart = user.cart
    foodlist = user.food_lists.where(food_list_type: "grocery_list").first
    # clean cart
    @cart.clean_cart
    # get list of cheapest store items from grocery list
    cheap_products = StoreItem.get_cheap_store_items(foodlist.foods)
    # fill cart with new items
    cheap_products.each do |product|
      @cart.add_product(product)
    end
  end

  private
  def carts_params
    params.require(:cart).permit(:cart_id, :user_id)
  end
end
