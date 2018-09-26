class CreateMetaRecipes < ActiveRecord::Migration[5.0]
  def change
    create_table :meta_recipes do |t|
      t.string :name
      t.integer :servings, default: 1
      t.text :ingredients
      t.text :instructions

      t.timestamps
    end
  end
end
