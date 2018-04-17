class RenameContentToName < ActiveRecord::Migration[5.0]
  def change
    rename_column :recommendations, :content, :name
  end
end
