class RemoveCartFromItems < ActiveRecord::Migration[5.0]
  def change
    remove_reference :items, :cart, foreign_key: true
  end
end
