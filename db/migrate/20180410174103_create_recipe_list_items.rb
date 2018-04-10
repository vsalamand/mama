class CreateRecipeListItems < ActiveRecord::Migration[5.0]
  def change
    create_table :recipe_list_items do |t|
      t.references :recipe, foreign_key: true
      t.references :recipe_list, foreign_key: true
      t.integer :position

      t.timestamps
    end
  end
end
