class AddPositionToStoreSections < ActiveRecord::Migration[5.0]
  def change
    add_column :store_sections, :position, :integer
  end
end
