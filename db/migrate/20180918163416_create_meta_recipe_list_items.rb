class CreateMetaRecipeListItems < ActiveRecord::Migration[5.0]
  def change
    create_table :meta_recipe_list_items do |t|
      t.references :meta_recipe_list, foreign_key: true
      t.references :meta_recipe, foreign_key: true
      t.string :name

      t.timestamps
    end
  end
end
