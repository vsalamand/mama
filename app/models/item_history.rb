class ItemHistory < ApplicationRecord
  belongs_to :item

  after_save do
    self.update_score
  end

  def self.create_history
    new_history_items = []

    Item.all.each do |i|
      # if we do not find a history item corresponding to the item
      unless ItemHistory.find_by(item_id: i.id, is_deleted: i.is_deleted).present?
        # create a history item when item is created and when its deleted/completed
        if i.is_deleted || i.is_completed
          new_history_items << ItemHistory.new(item_id: i.id, created_at: i.created_at, is_deleted: false)
          new_history_items << ItemHistory.new(item_id: i.id, created_at: i.updated_at, is_deleted: true)
        else
          new_history_items << ItemHistory.new(item_id: i.id, created_at: i.created_at, is_deleted: false)
        end
      end
    end

    ItemHistory.import new_history_items
  end

  def get_points
    item = Item.find(self.item_id)
    item.category.present? ? rating = item.category.rating.to_i  : rating = 0
    case rating
      when 0 then points = 0
      when 1 then points = 3
      when 2 then points = -1
      when 3 then points = -3
    end
    points = points * -1 if self.is_deleted
    return points
  end

  def self.get_score_progress(items, score, max)
    history_points = ItemHistory.where(item_id: items.pluck(:id)).order(:created_at).last(max).map{|ih| ih.get_points}
    start_score = score - history_points.inject(0){|sum,x| sum + x }
    new_history_points = Array(start_score) + history_points
    data = new_history_points.each_with_object([]){|e, a| a.push(a.last.to_i + e)}

    return (1..(max+1)).zip(data)
  end

  def self.get_score(items)
    item_histories = ItemHistory.where(item_id: items.pluck(:id))
    item_histories = item_histories.order(:created_at).map{|ih| ih.get_points}
    item_histories.sum
  end

  def update_score
    if self.item.list.present?
      points = self.get_points
      self.item.list.user.scores.first.add(points)
    end
  end
end
