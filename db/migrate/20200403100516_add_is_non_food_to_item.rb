class AddIsNonFoodToItem < ActiveRecord::Migration[5.0]
  def change
    add_column :items, :is_non_food, :boolean, null: false, default: false
  end
end
