class CreateStoreSectionItems < ActiveRecord::Migration[5.2]
  def change
    create_table :store_section_items do |t|
      t.string :name
      t.string :breadcrumb, array: true, default: []
      t.references :store, foreign_key: true
      t.references :store_section, foreign_key: true, optional: true
      t.integer :level

      t.timestamps
    end
  end
end
