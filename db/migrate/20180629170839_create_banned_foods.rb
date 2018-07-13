class CreateBannedFoods < ActiveRecord::Migration[5.0]
  def change
    create_table :banned_foods do |t|
      t.string :name
      t.references :diet, foreign_key: true
      t.references :food, foreign_key: true

      t.timestamps
    end
  end
end
