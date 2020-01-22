class AddStatusToRecipeList < ActiveRecord::Migration[5.0]
  def change
    add_column :recipe_lists, :status, :string, :default => "archived"
  end
end
