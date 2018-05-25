class AddRatingToCategory < ActiveRecord::Migration[5.0]
  def change
    add_column :categories, :rating, :string
  end
end
