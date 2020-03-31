class Checklist < ApplicationRecord
  # has_many :food_list_items, dependent: :destroy
  # has_many :foods, through: :food_list_items
  belongs_to :diet, optional: true
  has_many :lists, through: :checklist_items
  has_many :checklist_items, dependent: :destroy, inverse_of: :checklist

  accepts_nested_attributes_for :checklist_items, allow_destroy: true

  def get_curated_lists
    self.checklist_items.map{ |checklist_item| checklist_item.list if checklist_item.list.status == "saved" }.compact
  end
end
