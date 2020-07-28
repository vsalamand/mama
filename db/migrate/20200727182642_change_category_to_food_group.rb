class ChangeCategoryToFoodGroup < ActiveRecord::Migration[5.2]
  def change
    rename_table :categories, :food_groups
  end
end
