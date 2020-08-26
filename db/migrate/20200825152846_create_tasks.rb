class CreateTasks < ActiveRecord::Migration[5.2]
  def change
    create_table :tasks do |t|
      t.references :game, foreign_key: true
      t.string :name
      t.string :description, optional: true
      t.integer :max_steps, optional: true
      t.integer :score_per_step, optional: true

      t.timestamps
    end
  end
end
