require 'open-uri'
require 'httparty'

class List < ApplicationRecord
  belongs_to :user, optional: true
  has_many :list_items, dependent: :destroy
  has_many :items, through: :list_items
  has_many :foods, through: :items
  has_many :collaborations
  has_many :users, through: :collaborations
  has_many :store_carts, dependent: :destroy
  validates :name, presence: true
  has_many :checklist_items, dependent: :destroy, inverse_of: :list
  has_many :checklists, through: :checklist_items
  has_many :recipe_list_items, dependent: :destroy
  has_many :recipes, through: :recipe_list_items

  accepts_nested_attributes_for :list_items, allow_destroy: true
  accepts_nested_attributes_for :checklist_items

  STATUS = ["archived", "opened", "saved", "deleted"]
  LIST_TYPE = ["personal", "curated"]

  scope :saved, -> { where(status: "saved").where( is_deleted: false) }
  scope :opened, -> { where(status: "opened").where( is_deleted: false) }
  scope :archived, -> { where(status: "archived").where( is_deleted: false) }


  #create the soft delete method
  def delete
    update(is_deleted: true, status: "deleted")
    self.list_items.map{|list_item| list_item.delete }
  end

  # make an undelete method
  def undelete
    update(is_deleted: false, status: "opened")
  end

  def save_as_plugin
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

  def duplicate_list_items(list)
    list.list_items.not_deleted.each do |list_item|
      new_list_item = ListItem.create(name: list_item.name,
        list_id: self.id,
        deleted: list_item.deleted,
        is_completed: list_item.is_completed,
        position: list_item.position)

      valid_item = Item.where("lower(name) = ?", new_list_item.name.downcase).where(is_validated: true).first
      Thread.new do
        if valid_item.present?
          # Item.create(quantity: valid_item.quantity, unit: valid_item.unit, food: valid_item.food, list_item: @list_item, name: valid_item.name, is_validated: valid_item.is_validated)
          Item.create(food: valid_item.food, list_item: new_list_item, name: valid_item.food.name, is_validated: valid_item.is_validated)
        else
          Item.create_list_item(new_list_item)
        end
      end
    end
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

  def get_curated_food
    results = []
    User.find_by_email("mama@clubmama.co").lists.each do |list|
      results << list.foods.shuffle[0..3].pluck(:name).map{|x| x.downcase}
    end

    curated_foods = results.flatten - self.list_items.not_completed.pluck(:name).map{|x| x.downcase}
    return curated_foods
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

  # get list of most popular food in recipes
  def get_top_foods
    result = Food.left_joins(:recipes).group(:id).order('COUNT(recipes.id) DESC').limit(15).pluck(:name)
    # clean_top_foods = top_foods - List.get_seasonings
    top_foods = result - List.get_seasonings.pluck(:name).map{|x| x.downcase} - self.list_items.not_completed.pluck(:name).map{|x| x.downcase}
    return top_foods
  end

  def get_items_to_buy
    self.list_items.not_completed.map{ |list_item| list_item.item }
  end

  def get_not_completed
    self.list_items.not_completed
  end

  def get_sort_options
    return ["ordre d'ajout", "rayon"]
  end

  def sort_by_store_sections
    store_sections = ["Légumes", "Fruits", "Frais", "Surgelés", "Viandes & poissons", "Épicerie salée", "Épicerie sucrée", "Boissons", "Autres"]
    sort_by_sections = Hash[store_sections.map {|x| [x, Array.new]}]

    self.list_items.not_completed.each do |list_item|
      section = list_item.get_item.get_store_section.name
      if sort_by_sections.has_key?(section)
        sort_by_sections[section] << list_item
      else
        sort_by_sections[section] = Array(list_item)
      end
    end

    return sort_by_sections
  end

  def get_store_carts
    items = self.get_items_to_buy
    Store.all.each do |store|
      store_cart = StoreCart.find_or_create_by(store_id: store.id, list_id: self.id)
      store_cart.clean_store_cart
    end
    return self.store_carts
  end
end
