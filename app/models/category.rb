class Category < ApplicationRecord
  belongs_to :store_section
  belongs_to :food, optional: true
  has_ancestry
  has_many :store_section_items
  has_many :stores, through: :store_section_items

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

  def self.arrange_as_array(options={}, hash=nil)
    hash ||= arrange(options)

    arr = []
    hash.each do |node, children|
      arr << node
      arr += arrange_as_array(options, children) unless children.nil?
    end
    arr
  end

  def name_for_selects
    "#{'-' * depth} #{name}"
  end

  def possible_parents
    parents = Category.arrange_as_array(:order => 'name')
    return new_record? ? parents : parents - subtree
  end
end
