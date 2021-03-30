class AddIsVisibleToCategories < ActiveRecord::Migration[5.2]
  def change
    add_column :categories, :is_visible, :boolean, default: true
  end
end
