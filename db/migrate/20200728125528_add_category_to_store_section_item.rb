class AddCategoryToStoreSectionItem < ActiveRecord::Migration[5.2]
  def change
    add_reference :store_section_items, :category, foreign_key: true, optional: true
  end
end
