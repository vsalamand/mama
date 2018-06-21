class AddDietIdToUsers < ActiveRecord::Migration[5.0]
  def change
    add_reference :users, :diet, foreign_key: true
  end
end
