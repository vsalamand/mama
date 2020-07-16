class AddStoreSectionItemToStoreItem < ActiveRecord::Migration[5.2]
  def change
    add_reference :store_items, :store_section_item, foreign_key: true, optional: true
  end
end
