class CreateItems < ActiveRecord::Migration[5.0]
  def change
    create_table :items do |t|
      t.string :name
      t.references :ingredient, foreign_key: true
      t.references :recipe, foreign_key: true
      t.references :unit, foreign_key: true
      t.float :quantity

      t.timestamps
    end
  end
end
