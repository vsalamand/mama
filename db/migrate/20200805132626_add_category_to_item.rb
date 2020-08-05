class AddCategoryToItem < ActiveRecord::Migration[5.2]
  def change
    add_reference :items, :category, foreign_key: true, optional: true
  end
end
