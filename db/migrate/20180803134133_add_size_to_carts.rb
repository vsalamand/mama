class AddSizeToCarts < ActiveRecord::Migration[5.0]
  def change
    add_column :carts, :size, :integer
  end
end
