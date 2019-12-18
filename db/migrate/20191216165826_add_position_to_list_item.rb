class AddPositionToListItem < ActiveRecord::Migration[5.0]
  def change
    add_column :list_items, :position, :integer
  end
end
