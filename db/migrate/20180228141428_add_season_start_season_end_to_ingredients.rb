class AddSeasonStartSeasonEndToIngredients < ActiveRecord::Migration[5.0]
  def change
    add_column :ingredients, :season_start, :string, default: "01/01"
    add_column :ingredients, :season_end, :string, default: "12/31"
  end
end
