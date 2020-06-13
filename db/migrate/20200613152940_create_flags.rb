class CreateFlags < ActiveRecord::Migration[5.0]
  def change
    create_table :flags do |t|
      t.string :name
      t.datetime :created_at
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
