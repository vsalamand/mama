class FoodListItem < ApplicationRecord
  belongs_to :food, inverse_of: :food_list_items, optional: true
  belongs_to :food_list, optional: true
  belongs_to :checklist, optional: true
  # validates :name, presence: :true

  accepts_nested_attributes_for :food

  after_create do
    self.get_name if self.name.nil?
  end

  def get_name
    self.name = self.food.name
    self.save
  end

end
