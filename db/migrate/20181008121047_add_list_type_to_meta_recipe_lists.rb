class AddListTypeToMetaRecipeLists < ActiveRecord::Migration[5.0]
  def change
    add_column :meta_recipe_lists, :list_type, :string
  end
end
