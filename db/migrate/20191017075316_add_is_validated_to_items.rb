class AddIsValidatedToItems < ActiveRecord::Migration[5.0]
  def change
    add_column :items, :is_validated, :boolean, default: false
  end
end
