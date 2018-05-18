class CreateFoodLists < ActiveRecord::Migration[5.0]
  def change
    create_table :food_lists do |t|
      t.string :name
      t.references :user, foreign_key: true
      t.text :description
      t.string :food_list_type

      t.timestamps
    end
  end
end
