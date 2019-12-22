class List < ApplicationRecord
  belongs_to :user
  has_many :list_items, dependent: :destroy
  has_many :items, through: :list_items
  has_many :foods, through: :items
  validates :name, presence: true

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
        data = JSON.parse(open(url).read)
        result = data.map {|x| x.values[0]}

        suggested_foods = []
        # result.each { |food| suggested_foods << Food.search(food, fields: [{name: :exact}], misspellings: {edit_distance: 1}).first}
        result.each { |food| suggested_foods << Food.find_by(name: food) }

        # filter out seasonings and foods in shoppinglist
        # suggested_foods = suggested_foods - List.get_seasonings
        return suggested_foods
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
    top_foods = Food.left_joins(:recipes).group(:id).order('COUNT(recipes.id) DESC').limit(30)
    # clean_top_foods = top_foods - List.get_seasonings
    #  remove list of food in current list (take too long)
    # self.list_items.not_deleted.map{ |list_item| list_item.food }
    return top_foods
  end
end
