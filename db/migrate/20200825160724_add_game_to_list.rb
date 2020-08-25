class AddGameToList < ActiveRecord::Migration[5.2]
  def change
    add_reference :lists, :game, foreign_key: true, optional: true
  end
end
