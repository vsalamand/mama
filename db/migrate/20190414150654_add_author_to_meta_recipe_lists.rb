class AddAuthorToMetaRecipeLists < ActiveRecord::Migration[5.0]
  def change
    add_column :meta_recipe_lists, :author, :string
  end
end
