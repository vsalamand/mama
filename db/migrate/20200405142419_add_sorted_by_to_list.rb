class AddSortedByToList < ActiveRecord::Migration[5.0]
  def change
    add_column :lists, :sorted_by, :string
  end
end
