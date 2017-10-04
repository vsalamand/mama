class RemoveNamefromItems < ActiveRecord::Migration[5.0]
  def change
    remove_column :items, :name, :string
  end
end
