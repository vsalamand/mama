class ChangeEanToStringInProducts < ActiveRecord::Migration[5.0]

  def up
    change_column :products, :ean, :string
  end

  def down
    change_column :products, :ean, :bigint
  end
end
