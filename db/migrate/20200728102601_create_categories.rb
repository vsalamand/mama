class CreateCategories < ActiveRecord::Migration[5.2]
  def change
    create_table :categories do |t|
      t.string :name
      t.string :category_type
      t.references :store_section, foreign_key: true

      t.timestamps
    end
  end
end
