class CreateChecklists < ActiveRecord::Migration[5.0]
  def change
    create_table :checklists do |t|
      t.string :name
      t.string :checklist_type
      t.string :schedule

      t.timestamps
    end
  end
end
