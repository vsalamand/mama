class ChecklistItem < ApplicationRecord
  belongs_to :checklist
  belongs_to :list, inverse_of: :checklist_items

  accepts_nested_attributes_for :list


  # add name from list
  after_create do
    if self.name.blank?
      self.get_name
    end
  end

  def get_name
    self.name = self.list.name
    self.save
  end
end
