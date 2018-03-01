class RemoveSeasonStartSeasonEndFromIngredients < ActiveRecord::Migration[5.0]
  def change
    remove_column :ingredients, :season_start, :string
    remove_column :ingredients, :season_end, :string
  end
end
