class AddLevelToCategory < ActiveRecord::Migration[5.2]
  def change
    add_column :categories, :level, :integer
  end
end
