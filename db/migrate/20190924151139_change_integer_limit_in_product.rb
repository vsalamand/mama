class ChangeIntegerLimitInProduct < ActiveRecord::Migration[5.0]
  def change
    change_column :products, :ean, :integer, limit: 8
  end
end
