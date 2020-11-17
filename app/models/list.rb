require 'open-uri'
require 'httparty'

class List < ApplicationRecord
  audited max_audits: 3
  has_associated_audits

  extend FriendlyId
  friendly_id :name, use: :history

  belongs_to :user, optional: true
  belongs_to :game, optional: true
  has_many :list_items, dependent: :destroy
  has_many :items
  has_many :foods, through: :items
  has_many :categories, through: :items
  has_many :collaborations
  has_many :users, through: :collaborations
  has_many :store_carts, dependent: :destroy
  validates :name, presence: true
  has_many :checklist_items, dependent: :destroy, inverse_of: :list
  has_many :checklists, through: :checklist_items
  has_many :recipe_list_items, dependent: :destroy
  has_many :recipes, through: :recipe_list_items
  has_many :tasks, through: :game
  has_many :task_items

  accepts_nested_attributes_for :list_items, allow_destroy: true
  accepts_nested_attributes_for :items, allow_destroy: true
  accepts_nested_attributes_for :checklist_items

  STATUS = ["archived", "opened", "saved", "deleted"]
  LIST_TYPE = ["personal", "curated"]

  scope :saved, -> { where(status: "saved").where( is_deleted: false) }
  scope :opened, -> { where(status: "opened").where( is_deleted: false) }
  scope :archived, -> { where(status: "archived").where( is_deleted: false) }


  #create the soft delete method
  def delete
    update(is_deleted: true, status: "deleted")
    self.items.not_deleted.each{|item| item.delete }
  end

  # make an undelete method
  def undelete
    update(is_deleted: false, status: "opened")
  end

  def saved
    self.status = "saved"
    self.save
  end

  def archive
    self.status = "archived"
    self.save
  end

  def open
    self.status = "opened"
    self.save
  end

  def duplicate_list(user)
    new_list = List.new
    new_list.name = self.name
    new_list.user_id = user.id
    new_list.status = "saved"
    new_list.sorted_by = "rayon"
    new_list.save
    if self.recipes.any?
      self.recipes.each{|r| r.add_recipe_to_list(new_list.id) }
    end
    return new_list
  end

  def get_products
    list_products = []
    self.list_items.not_deleted.each do |list_item|
      dic = Hash.new
      dic["list_item"] = list_item.id
      dic["item"] = list_item.items.last.id if list_item.items.any?
      dic["store_item"] = list_item.item.food.get_cheapest_store_item_id if list_item.item.present? && list_item.item.food.present?
      list_products << dic
    end
    return list_products
  end

  def get_uncomplete_list_items_items
    return self.list_items.not_completed.map{ |list_item| list_item.item }.compact
  end

  # get list of similar foods from smartmama
  def get_similar_food
    curated_foods = self.get_curated_food
    if self.foods.any?
      begin
        items = []
        # self.foods.map {|x| x.name}.each { |food| items << "item=#{food}"}
        last_food = self.list_items.not_deleted.last.food.first.name
        items << "item=#{last_food}"
        url = URI.parse(URI::encode("https://smartmama.herokuapp.com/api/v1/predict?#{items.join("&")}"))
        data = HTTParty.get(url)
        result = data.map {|x| x.values[0].downcase}

        # suggested_foods = []
        # # result.each { |food| suggested_foods << Food.search(food, fields: [{name: :exact}], misspellings: {edit_distance: 1}).first}
        # result.each { |food| suggested_foods << Food.find_by(name: food) }

        # # filter out seasonings and foods in shoppinglist
        suggested_foods = result - List.get_seasonings.pluck(:name).map{|x| x.downcase} - self.list_items.not_completed.pluck(:name).map{|x| x.downcase}
        return suggested_foods[0..2] + curated_foods[0..9]
      rescue
        return curated_foods
      end
    else
      return curated_foods
    end
  end

  def get_similar_products
    # find recipe ids that contains product from user
    recipe_ids = Item.where(recipe_id: Recipe.where(status: "published").pluck(:id), category_id: Category.find(list.items.not_deleted.pluck(:category_id).compact.pluck(:id))).pluck(:recipe_id).sort.reverse.last(150)
    similar = Item.where(recipe_id: recipe_ids).pluck(:category_id).compact.group_by{|x| x}.sort_by{|k, v| -v.size}.map(&:first)

    Category.find(similar - Category.get_seasonings)

  end

  # get list of seasonings
  def self.get_seasonings
    category_ids = []
    # sel
    category_ids << Category.find(10).child_ids
    # matières grasses ajoutées
    category_ids << Category.find(6).child_ids
    # herbes ou épices
    category_ids << Category.find(43).child_ids

    seasonings = Food.where("category_id IN (?)", category_ids.flatten) + Category.find(14).foods.tagged_with("légumes bulbes")
    return seasonings
  end

  def get_sort_options
    return ["date", "rayon", "category", "foodgroup"]
  end

  def sort_by_store_sections
    store_sections = StoreSection.order(:position).pluck(:name)
    store_sections << "Non-alimentaires"
    data = Hash[store_sections.map {|x| [x, Array.new]}]

    self.get_not_deleted.each do |list_item|
      section = list_item.get_store_section
      data[section] << list_item
    end

    return data
  end

  def get_store_section_items(store_section)
     Item.where(is_deleted: false,
                is_completed: false,
                list_id: self.id,
                store_section_id: store_section.id)
  end

  def get_foodgroup_items(foodgroup)
    Item.where(is_deleted: false,
               list_id: self.id,
               category_id: Category.where(:food_group_id => foodgroup.subtree.pluck(:id)).map{ |c| c.subtree }.flatten.uniq)
  end

  def get_good_and_limit_foodgroup_items(foodgroup)
    Item.where(is_deleted: false,
               is_completed: false,
               list_id: self.id,
               category_id: Category.where(rating: [1, 2]).where(:food_group_id => foodgroup.subtree.pluck(:id)).map{ |c| c.subtree }.flatten.uniq)
  end

  def get_rated_items(rating_array)
    Item.where(is_deleted: false,
               is_completed: false,
               list_id: self.id,
               category_id: Category.where(rating: rating_array).pluck(:id))
  end

  def get_saved_items
    self.items.where(is_completed: true)
  end

  def unsave_items(item)
    if item.category.present?
      items_to_delete = self.items.where(is_completed: true).where.not(category_id: nil).where(category_id: item.category.id)
      items_to_delete.each{ |i| i.delete } if items_to_delete.any?
    end
  end

  def get_store_carts
    items = self.get_items_to_buy
    Store.all.each do |store|
      store_cart = StoreCart.find_or_create_by(store_id: store.id, list_id: self.id)
      store_cart.clean_store_cart
    end
    return self.store_carts
  end

  def get_last_edit(user_id)
    Time.zone = "Europe/Paris"
    event = self.own_and_associated_audits.first
    user = User.find(user_id)
    unless  event.nil? || event.user == user || event.user.nil?
      email = event.user.email.split('@')[0]
      email = "vous" if event.user == user
      day = event.created_at
      time = "#{day.strftime('%H')}h#{day.strftime('%M')}"
      if day.today?
        day = ""
      elsif day.to_date == Date.yesterday
        day = "hier"
      else
        day = "il y a #{(day.to_date..Date.today).count - 1} jours"
      end
      if day.empty?
        message = "Mise à jour à #{time} par #{email}"
      else
        message = "Mise à jour #{day} par #{email}"
      end
      return message
    else
      return nil
    end
  end

  def get_suggestions
    data = []

    user_history = Category.get_user_category_ids_history(self.user)
    seasonings = Category.get_seasonings
    snoozed = Category.get_user_snoozed_category_ids(self.user)
    banned_products = user_history + seasonings + snoozed

    top_user_category_ids = Category.get_top_user_category_ids(self.user)
    top_recipe_category_ids = Category.get_top_recipe_category_ids
    top_added_category_ids = Category.get_top_added_category_ids


    cleaned_top_user_category_ids = (top_user_category_ids - banned_products)
    if cleaned_top_user_category_ids.size < 10
      cleaned_top_user_category_ids = cleaned_top_user_category_ids.fill(nil, cleaned_top_user_category_ids.size...15)
    end
    user_tops = cleaned_top_user_category_ids.map{|id| {id: id, context: "user_top"}}.each_slice(2).to_a
    data << user_tops

    recipe_tops = (top_recipe_category_ids - banned_products).map{|id| {id: id, context: "recipe_top"}}.each_slice(2).to_a
    data << recipe_tops

    Checklist.find_by(name: "healthy").checklist_items.each do |checklist|
      category_ids = (top_recipe_category_ids & checklist.list.categories.pluck(:id))
      data << (category_ids - banned_products).map{|id| {id: id, context: "recommended"}}.each_slice(1).to_a if (user_history & category_ids).empty?
    end


    data = data.select(&:present?)
    data = data.first.zip(*data[1..].shuffle)
                    .flatten
                    .compact
                    .uniq! {|e| e[:id] }

    # return array of hashes
    return data
  end

  def get_score
    Task.set_bonus_scores(self)
    points = []
    # check bonus points
    points << self.task_items.map{ |t| t.get_score} if self.task_items.any?
    # get green points
    points << self.get_rated_items([1]).size * 3
    # get yellow points
    points << self.get_rated_items([2]).size * -1
    # get red points
    points << self.get_rated_items([3]).size * -3

    return points.flatten.compact.reduce(:+)
  end

  def set_game
    self.game = Game.first
    self.save
    Game.first.tasks.each{ |t| TaskItem.find_or_create_by(list_id: self.id, task_id: t.id) }
    self.get_score
    # self.tasks.each{ |t| t.get_score(self)}
  end

  def should_generate_new_friendly_id?
    slug.blank? || name_changed?
  end
end
