class AddDietToChecklist < ActiveRecord::Migration[5.0]
  def change
    add_reference :checklists, :diet, foreign_key: true
  end
end
