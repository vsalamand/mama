class CreateBannedCategory < ActiveRecord::Migration[5.0]
  def change
    create_table :banned_categories do |t|
      t.string :name
      t.references :category, foreign_key: true
      t.references :diet, foreign_key: true
    end
  end
end
