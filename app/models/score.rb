class Score < ApplicationRecord
  belongs_to :user
  belongs_to :game

  def set_score
    items = self.user.items.where(list_id: self.user.get_lists.pluck(:id))
    self.value = ItemHistory.get_score(items)
    self.save
  end

  def add(points)
    self.value += points
    self.save
  end
end
