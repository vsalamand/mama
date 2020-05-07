class AddStoreSectionIdToFood < ActiveRecord::Migration[5.0]
  def change
    add_reference :foods, :store_section, foreign_key: true
  end
end
