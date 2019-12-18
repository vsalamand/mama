class CreateDiets < ActiveRecord::Migration[5.0]
  def change
    create_table :diets do |t|
      t.string :name
      t.text :description
      t.boolean :is_active
      t.timestamps
    end
  end
end