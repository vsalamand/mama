class RemoveForeignKey < ActiveRecord::Migration[5.0]
  def change
    remove_reference :recommendations, :diet, index: true, foreign_key: true
  end
end
