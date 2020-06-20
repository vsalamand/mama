class AddDataToFlags < ActiveRecord::Migration[5.0]
  def change
    add_column :flags, :data, :string
  end
end
