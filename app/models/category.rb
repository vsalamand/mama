class Category < ApplicationRecord
  belongs_to :store_section
  belongs_to :food_group
  belongs_to :food, optional: true
  has_many :store_section_items
  has_many :stores, through: :store_section_items
  has_many :items

  has_ancestry
  searchkick language: "french"

  before_save do
    self.update_related_items_store_section_id if will_save_change_to_store_section_id?
  end

  def update_related_items_store_section_id
    Item.where(category: self).where(store_section_id: self.store_section_id_was).update_all(store_section_id: self.store_section_id)
  end

  def search_data
    {
      name: name
    }
  end

  def get_store_section
    self.path.reverse.each do |c|
      if c.store_section.present?
        return c.store_section
        break
      end
    end
    return nil
  end

  def get_food_group
    self.path.reverse.each do |c|
      if c.food_group.present?
        return c.food_group
        break
      end
    end
    return nil
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
