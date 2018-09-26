class CreateMetaRecipeItems < ActiveRecord::Migration[5.0]
  def change
    create_table :meta_recipe_items do |t|
      t.references :meta_recipe, foreign_key: true
      t.references :food, foreign_key: true
      t.string :ingredient

      t.timestamps
    end
  end
end
