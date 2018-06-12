class RemoveChecklistTypeFromChecklist < ActiveRecord::Migration[5.0]
  def change
    remove_column :checklists, :checklist_type, :string
  end
end
