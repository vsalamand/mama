class AddListItemToItems < ActiveRecord::Migration[5.0]
  def change
    add_reference :items, :list_item, foreign_key: true
  end
end
