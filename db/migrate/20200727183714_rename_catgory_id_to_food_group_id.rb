class RenameCatgoryIdToFoodGroupId < ActiveRecord::Migration[5.2]
  def change
    rename_column :foods, :category_id, :food_group_id
  end
end
