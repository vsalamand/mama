class CreateItemHistories < ActiveRecord::Migration[5.2]
  def change
    create_table :item_histories do |t|
      t.references :item, foreign_key: true
      t.boolean :is_deleted, default: false

      t.timestamps
    end
  end
end
