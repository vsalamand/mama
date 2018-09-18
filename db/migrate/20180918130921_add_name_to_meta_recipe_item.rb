class AddNameToMetaRecipeItem < ActiveRecord::Migration[5.0]
  def change
    add_column :meta_recipe_items, :name, :string
  end
end
