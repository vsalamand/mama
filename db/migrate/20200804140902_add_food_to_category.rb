class AddFoodToCategory < ActiveRecord::Migration[5.2]
  def change
    add_reference :categories, :food, foreign_key: true, optional: true
  end
end
