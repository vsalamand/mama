class AddIsActiveToDiet < ActiveRecord::Migration[5.0]
  def change
    add_column :diets, :is_active, :boolean
  end
end
