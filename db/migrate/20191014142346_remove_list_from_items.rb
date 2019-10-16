class RemoveListFromItems < ActiveRecord::Migration[5.0]
  def change
    remove_reference :items, :list, index: true, foreign_key: true
  end
end
