class AddColumsToFoods < ActiveRecord::Migration[5.0]
  def change
    add_column :foods, :measure, :string, optional: true
    add_column :foods, :serving, :float, optional: true
    add_column :foods, :unit_per_piece, :float, optional: true
    add_reference :foods, :unit, foreign_key: true, optional: true
  end
end
