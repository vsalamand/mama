class UpdateForeignKeyAddOnDeleteConstraint < ActiveRecord::Migration[5.0]
  def change
    remove_foreign_key :orders, :carts
    add_foreign_key :orders, :carts, on_delete: :cascade
  end
end
