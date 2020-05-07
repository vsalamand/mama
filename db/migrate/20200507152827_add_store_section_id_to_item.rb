class AddStoreSectionIdToItem < ActiveRecord::Migration[5.0]
  def change
    add_reference :items, :store_section, foreign_key: true
  end
end
