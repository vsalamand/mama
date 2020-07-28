class Category < ApplicationRecord
  belongs_to :store_section
  has_ancestry

  def get_store_section
    if self.store_section.present?
      return self.store_section
    elsif self.parent.present? && self.parent.store_section.present?
      return self.parent.store_section
    elsif self.root.present? && self.root.store_section.present?
      return self.root.store_section
    else
      return nil
    end
  end
end
