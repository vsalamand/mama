class List < ApplicationRecord
  belongs_to :user
  has_many :list_items, dependent: :destroy
  has_many :items, through: :list_items
  has_many :foods, through: :items
  validates :name, presence: true


  def get_products
    list_products = []
    self.list_items.not_deleted.each do |list_item|
      dic = Hash.new
      dic["list_item"] = list_item.id
      dic["item"] = list_item.items.last.id if list_item.items.any?
      dic["store_item"] = list_item.items.last.food.get_cheapest_store_item_id if list_item.items.any? && list_item.items.last.food.present?
      list_products << dic
    end
    return list_products
  end
end
