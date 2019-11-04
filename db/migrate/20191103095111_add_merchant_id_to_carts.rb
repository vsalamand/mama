class AddMerchantIdToCarts < ActiveRecord::Migration[5.0]
  def change
    add_reference :carts, :merchant, foreign_key: true, optional: true
  end
end
