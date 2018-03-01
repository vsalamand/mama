class RenameIngredientsTableToFoodsTable < ActiveRecord::Migration[5.0]
  def change
     rename_table :ingredients, :foods
  end
end
