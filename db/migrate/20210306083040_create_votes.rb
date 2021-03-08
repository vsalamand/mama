class CreateVotes < ActiveRecord::Migration[5.2]
  def change
    create_table :votes do |t|
      t.references :recipe_list_item, foreign_key: true
      t.references :user, foreign_key: true, optional: true

      t.timestamps
    end
  end
end
