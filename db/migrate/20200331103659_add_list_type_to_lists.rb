class AddListTypeToLists < ActiveRecord::Migration[5.0]
  def change
    add_column :lists, :list_type, :string, default: "personal"
  end
end
