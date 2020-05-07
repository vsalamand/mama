class CreateStoreSections < ActiveRecord::Migration[5.0]
  def change
    create_table :store_sections do |t|
      t.string :name

      t.timestamps
    end
  end
end
