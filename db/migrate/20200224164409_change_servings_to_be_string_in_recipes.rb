class ChangeServingsToBeStringInRecipes < ActiveRecord::Migration[5.0]
  def up
    change_column :recipes, :servings, :string
  end

  def down
    change_column :recipes, :servings, :integer
  end
end
