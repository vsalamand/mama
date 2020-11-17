class Category < ApplicationRecord
  belongs_to :store_section
  belongs_to :food_group
  belongs_to :food, optional: true
  has_many :store_section_items
  has_many :stores, through: :store_section_items
  has_many :items
  has_many :item_histories, through: :items

  has_ancestry
  searchkick language: "french"

  before_save do
    self.update_related_items_store_section_id if will_save_change_to_store_section_id?
  end

  after_update do
    self.update_score if saved_change_to_rating?
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

  def self.get_match(content)
    content = content.squeeze(' ')
    valid_item = Item.where("lower(trim(name)) = ?", content.downcase.strip).where(is_validated: true).first
    if valid_item.present?
      category = valid_item.category
    else
      query = "query=#{content}"
      url = URI.parse(URI::encode("https://smartmama.herokuapp.com/api/v1/parse/items?#{query}"))
      # url = URI.parse(URI::encode("http://127.0.0.1:5000/api/v1/parse/items?#{query}"))
      parser = JSON.parse(open(url).read).first
      category = Category.search(parser['food_match'], misspellings: {edit_distance: 1}).first if parser['food_match'].present?
      if category.nil? && parser['clean_item'].present?
        product = StoreItem.search(parser['clean_item'], where: {store_id: 1}).first
        category = product.get_category if product.present?
      end
    end
    return category
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
    # tops = Recipe.where(status: "published")
    tops = Recommendation.last.recipe_lists.first.recipes.where(status: "published")
                 .joins(:categories)
                 .where( categories: {id: self.id} )
                 .last(15)
                 .map{ |r| r.categories}
                 .flatten
                 .group_by{|x| x}
                 .sort_by{|k, v| -v.size}
                 .map(&:first)
                 .pluck(:id)
    banned = list.items.not_deleted.pluck(:category_id).compact + Category.get_seasonings
    results = tops - banned
    return Category.find(results[0..24])
  end

  def get_similar_categories
    recipe_ids =  Item.where(recipe_id: Recipe.where(status: "published").pluck(:id))
                      .where(category_id: self.id)
                      .pluck(:recipe_id)
    similars = Item.where(recipe_id: recipe_ids)
                    .pluck(:category_id)
                    .group_by{|x| x}
                    .sort_by{|k, v| -v.size}
                    .map(&:first)
                    .compact
    banned = Array(self.id) + Category.get_seasonings
    results = similars - banned
    return Category.find(results)
  end


  def self.get_top_recipe_categories(list)
    # tops = Recipe.where(status: "published")
    tops = Recommendation.last.recipe_lists.first.recipes.where(status: "published")
                  .last(15)
                  .map{ |r| r.categories}
                  .flatten
                  .group_by{|x| x}
                  .sort_by{|k, v| -v.size}
                  .map(&:first)
                  .pluck(:id)
    banned = list.items.not_deleted.pluck(:category_id).compact + Category.get_seasonings
    results = tops - banned
    return Category.find(results[0..24])
  end

  def self.get_seasonings
    ids = []
    ids << Category.find(280).subtree.pluck(:id)
    ids << Array(Category.find(605)).pluck(:id)
    ids << Array(Category.find(440)).pluck(:id)
    ids << Array(Category.find(812)).pluck(:id)
    ids << Array(Category.find(603)).pluck(:id)
    ids << Array(Category.find(505)).pluck(:id)
    ids << Category.find(87).subtree.pluck(:id)
    ids << Category.find(604).subtree.pluck(:id)
    ids << Category.find(499).subtree.pluck(:id)
    ids << Category.find(5).subtree.pluck(:id)
    ids << Category.find(726).subtree.pluck(:id)
    ids << Category.find(279).subtree.pluck(:id)
    ids << Category.find(793).subtree.pluck(:id)
    ids << Category.find(538).subtree.pluck(:id)
    ids << Category.find(282).subtree.pluck(:id)
    ids << Category.find(603).subtree.pluck(:id)
    ids << Category.find(727).subtree.pluck(:id)
    return ids.flatten
  end

  def self.get_top_user_category_ids(user)
    ids =  Item.where(['created_at > ?', 30.days.ago])
                    .where(list_id: user.get_lists.pluck(:id))
                    .pluck(:category_id)
                    .group_by{|x| x}.sort_by{|k, v| -v.size}
                    .map(&:first)
                    .compact
    data = ids[0..5].shuffle + ids[6..-1]
    return data
  end

  def self.get_user_category_ids_history(user)
    return Item.where(['created_at > ?', 7.days.ago])
                        .where(list_id: user.get_lists.pluck(:id))
                        .pluck(:category_id)
                        .uniq
                        .compact
  end

  def self.get_user_snoozed_category_ids(user)
    return Item.where(list_id: user.get_dislikes_list).pluck(:category_id)
  end

  def self.get_top_recipe_category_ids
    ids = Item.where(recipe_id: Recipe.where(status: "published").last(50).pluck(:id))
                      .pluck(:category_id)
                      .group_by{|x| x}
                      .sort_by{|k, v| -v.size}
                      .map(&:first)
                      .compact
    data = ids[0..5].shuffle + ids[6..-1]
    return data
  end

  def self.get_top_added_category_ids
    ids = Item.where(['created_at > ?', 7.days.ago])
                      .where.not(list_id: nil)
                      .pluck(:category_id)
                      .group_by{|x| x}
                      .sort_by{|k, v| -v.size}
                      .map(&:first)
                      .compact
    data = ids[0..5].shuffle + ids[6..-1]
    return data
  end

  def self.get_suggestions
    data = []

    seasonings = Category.get_seasonings
    banned_products = seasonings

    top_recipe_category_ids = Category.get_top_recipe_category_ids
    top_added_category_ids = Category.get_top_added_category_ids

    recipe_tops = (top_recipe_category_ids - banned_products).map{|id| {id: id, context: "recipe_top"}}.each_slice(2).to_a
    data << recipe_tops

    Checklist.find_by(name: "healthy").checklist_items.each do |checklist|
      category_ids = (top_recipe_category_ids & checklist.list.categories.pluck(:id))
      data << (category_ids - banned_products).map{|id| {id: id, context: "recommended"}}.each_slice(1).to_a
    end

    global_tops = (top_added_category_ids - banned_products).map{|id| {id: id, context: "global_top"}}.each_slice(2).to_a
    data << global_tops

    data = data.select(&:present?)
    data = data.first.zip(*data[1..].shuffle)
                    .flatten
                    .compact
                    .uniq! {|e| e[:id] }

    # return array of hashes
    return data

  end

  def get_points
    case self.rating
      when 0 then points = 0
      when 1 then points = 3
      when 2 then points = -1
      when 3 then points = -3
    end
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

  def update_score
    Thread.new do
      Score.all.each{ |s| s.set_score }
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
