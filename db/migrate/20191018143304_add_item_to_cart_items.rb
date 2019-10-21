class AddItemToCartItems < ActiveRecord::Migration[5.0]
  def change
    add_reference :cart_items, :item, foreign_key: true, optional: true
  end
end
