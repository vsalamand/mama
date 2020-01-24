require 'open-uri'
require 'httparty'

class List < ApplicationRecord
  belongs_to :user
  has_many :list_items, dependent: :destroy
  has_many :items, through: :list_items
  has_many :foods, through: :items
  has_many :collaborations
  has_many :users, through: :collaborations
  has_many :store_carts, dependent: :destroy
  validates :name, presence: true

  STATUS = ["archived", "opened", "saved"]

  scope :saved, -> { where(status: "saved") }
  scope :opened, -> { where(status: "opened") }
  scope :archived, -> { where(status: "archived") }


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

  def duplicate_list
    new_list = List.new
    new_list.name = self.name + " du #{Date.today.strftime("%d/%m/%Y")}"
    new_list.user_id = user.id
    new_list.status = "opened"
    new_list.save
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
      dic["store_item"] = list_item.items.last.food.get_cheapest_store_item_id if list_item.items.any? && list_item.items.last.food.present?
      list_products << dic
    end
    return list_products
  end

  # get list of similar foods from smartmama
  def get_similar_food
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
        return suggested_foods[0..9]
      rescue
        return nil
      end
    else
      return nil
    end
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
end
