class AddContextToOrders < ActiveRecord::Migration[5.0]
  def change
    add_column :orders, :context, :string
  end
end
