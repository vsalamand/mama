class UpdateCartItemsForeignKeyAddOnDeleteConstraintToOrders < ActiveRecord::Migration[5.0]
  def change
    remove_foreign_key :cart_items, :orders
    add_foreign_key :cart_items, :orders, on_delete: :cascade
  end
end
