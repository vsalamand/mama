class AddAncestryToStoreSectionItem < ActiveRecord::Migration[5.2]
  def change
    add_column :store_section_items, :ancestry, :string
    add_index :store_section_items, :ancestry
  end
end
