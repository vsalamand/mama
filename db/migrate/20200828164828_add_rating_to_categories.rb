class AddRatingToCategories < ActiveRecord::Migration[5.2]
  def change
    add_column :categories, :rating, :integer
  end
end
