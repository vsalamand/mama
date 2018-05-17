class CreateFoodListItems < ActiveRecord::Migration[5.0]
  def change
    create_table :food_list_items do |t|
      t.string :name
      t.references :food, foreign_key: true
      t.references :food_list, foreign_key: true, optional: true
      t.references :checklist, foreign_key: true, optional: true

      t.timestamps
    end
  end
end
