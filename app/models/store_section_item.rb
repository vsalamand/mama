class StoreSectionItem < ApplicationRecord
  has_ancestry
  belongs_to :store
  belongs_to :store_section
  has_many :store_items


  def self.clean_breadcrumb(text)
    breadcrumd = []

    text.each_with_index do |s, i|
      if s.start_with?(",")
        t = s + "'" + text[i+1]
        t = t[1..]
        breadcrumd << t.strip!.delete('\\"')
      elsif text[i-1].start_with?(",")
        next
      else
        breadcrumd << s
      end
    end

    return breadcrumd
  end

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
