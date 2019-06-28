class AddColumnsToMetaRecipeItems < ActiveRecord::Migration[5.0]
  def change
    add_reference :meta_recipe_items, :unit, foreign_key: true, optional: true
    add_column :meta_recipe_items, :quantity, :float, optional: true
  end
end
