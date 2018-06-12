class AddDietToFoodLists < ActiveRecord::Migration[5.0]
  def change
    add_reference :food_lists, :diet, foreign_key: true
  end
end
