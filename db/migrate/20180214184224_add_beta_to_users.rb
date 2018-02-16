class AddBetaToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :beta, :boolean, default: false
  end
end
