class AddAvailabilityToIngredients < ActiveRecord::Migration[5.0]
  def change
    add_column :ingredients, :availability, :string, default: "01, 02, 03, 04, 05, 06, 07, 08, 09, 10, 11, 12"
  end
end
