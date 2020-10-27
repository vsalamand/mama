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

  def set_store_section
    if self.store_section_id.nil?
      store_section = self.get_store_section
      if store_section.present?
        self.store_section_id = store_section.id
        self.save
      end
    end
  end

  def create_item
    if self.store_section_id.present?
      Item.find_or_create_by(
        category_id: self.id,
        name: self.name.downcase,
        store_section_id: self.store_section_id,
        is_non_food: false,
        is_validated: true,
        list_id: nil
      )
    end
  end

  def get_top_categories(list)
    tops = Recipe.joins(:categories)
                        .where( categories: {id: self.id} )
                        .map{ |r| r.categories}
                        .flatten
                        .group_by{|x| x}
                        .sort_by{|k, v| -v.size}
                        .map(&:first)
    banned = list.categories + Category.find(280).subtree + Array(Category.find(605)) + Array(Category.find(440)) + Array(Category.find(812)) + Array(Category.find(603)) + Array(Category.find(505)) + Category.find(87).subtree + Category.find(604).subtree + Category.find(499).subtree + Category.find(5).subtree + Category.find(726).subtree + Category.find(279).subtree + Category.find(793).subtree
    results = tops - banned
    return results[0..24]
  end

  def self.get_top_recipe_categories(list)
    tops = Recipe.last(25).map{ |r| r.categories}
                        .flatten
                        .group_by{|x| x}
                        .sort_by{|k, v| -v.size}
                        .map(&:first).pluck(:id)
    banned = list.items.not_deleted.pluck(:category_id).compact + Category.find(280).subtree.pluck(:id) + Array(Category.find(605)).pluck(:id) + Array(Category.find(440)).pluck(:id) + Array(Category.find(812)).pluck(:id) + Array(Category.find(603)).pluck(:id) + Array(Category.find(505)).pluck(:id) + Category.find(87).subtree.pluck(:id) + Category.find(604).subtree.pluck(:id) + Category.find(499).subtree.pluck(:id) + Category.find(5).subtree.pluck(:id) + Category.find(726).subtree.pluck(:id) + Category.find(279).subtree.pluck(:id) + Category.find(793).subtree.pluck(:id)
    results = tops - banned
    return Category.find(results[0..24])
  end

  def set_foodgroup_rating
    rating = self.get_food_group.rating if self.get_food_group.present?
    case rating
    when "good" then self.rating = 1
    when "limit" then self.rating = 2
    when "avoid" then self.rating = 3
    end
    self.save
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
