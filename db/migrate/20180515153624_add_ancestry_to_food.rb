class AddAncestryToFood < ActiveRecord::Migration[5.0]
  def change
    add_column :foods, :ancestry, :string
    add_index :foods, :ancestry
  end
end
