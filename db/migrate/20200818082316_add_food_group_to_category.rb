class AddFoodGroupToCategory < ActiveRecord::Migration[5.2]
  def change
    add_reference :categories, :food_group, foreign_key: true, optional: true
  end
end
