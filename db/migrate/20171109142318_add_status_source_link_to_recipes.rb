class AddStatusSourceLinkToRecipes < ActiveRecord::Migration[5.0]
  def change
    add_column :recipes, :status, :string
    add_column :recipes, :origin, :string
    add_column :recipes, :link, :string
  end
end
