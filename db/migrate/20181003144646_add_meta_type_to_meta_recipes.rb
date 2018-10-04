class AddMetaTypeToMetaRecipes < ActiveRecord::Migration[5.0]
  def change
    add_column :meta_recipes, :meta_type, :string
  end
end
