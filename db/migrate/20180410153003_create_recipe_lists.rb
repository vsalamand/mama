class CreateRecipeLists < ActiveRecord::Migration[5.0]
  def change
    create_table :recipe_lists do |t|
      t.string :name
      t.references :user, foreign_key: true
      t.text :description
      t.string :type

      t.timestamps
    end
  end
end
