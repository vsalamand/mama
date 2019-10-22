class AddIsReportedToProducts < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :is_reported, :boolean, default: false
  end
end
