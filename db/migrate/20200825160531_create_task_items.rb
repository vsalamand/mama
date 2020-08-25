class CreateTaskItems < ActiveRecord::Migration[5.2]
  def change
    create_table :task_items do |t|
      t.references :task, foreign_key: true
      t.references :list, foreign_key: true
      t.integer :step_count, default: 0
      t.integer :score, default: 0
      t.boolean :is_completed, default: false

      t.timestamps
    end
  end
end
