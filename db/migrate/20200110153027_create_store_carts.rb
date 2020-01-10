class CreateStoreCarts < ActiveRecord::Migration[5.0]
  def change
    create_table :store_carts do |t|
      t.references :user, foreign_key: true
      t.references :store, foreign_key: true
      t.references :list, foreign_key: true, optional: true
      t.references :recipe, foreign_key: true, optional: true

      t.timestamps
    end
  end
end
