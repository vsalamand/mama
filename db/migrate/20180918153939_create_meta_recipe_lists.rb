class CreateMetaRecipeLists < ActiveRecord::Migration[5.0]
  def change
    create_table :meta_recipe_lists do |t|
      t.string :name
      t.references :recipe, foreign_key: true

      t.timestamps
    end
  end
end
