class StoreItem < ApplicationRecord
  require 'csv'
  require 'rake'

  belongs_to :product
  belongs_to :store
  has_many :store_item_histories, dependent: :destroy
  has_many :store_cart_items, dependent: :destroy
  has_one :food, through: :product
  has_many :cart_items, :as => :productable
  has_one :unit, through: :product
  # to avoid duplicate carrefour products...
  validates :url, uniqueness: true


  def get_best_price
    best_price = self.is_promo ? self.price * (self.promo_price_per_unit / self.price_per_unit) : self.price
    return sprintf("%.2f", best_price)
  end

  def get_quantity
    product = self.product
    quantity = (product.quantity.to_i == product.quantity) ? product.quantity.to_i : product.quantity
    return "#{'x' unless product.unit.present?}#{quantity} #{product.unit.name if product.unit.present?}"
  end

  def self.get_shelf_store_items(store, shelf)
    StoreItem.where(store: store).pluck(:id, :shelters).select{ |store_item| store_item.second.include?(shelf)}[0..99]
  end

  def self.get_cheap_store_items(list, merchant)
    merchant_products = []
    list.list_items.not_deleted.each do |list_item|
      dic = Hash.new
      dic["list_item"] = list_item.id
      dic["item"] = list_item.items.last.id if list_item.items.any?
      if list_item.items.any? && list_item.items.last.food.present?
        dic["store_item"] = StoreItem.get_cheapest_store_item(list_item.items.last.food, merchant)
      else
        # if no item.food, then search best product match and get product food
        dic["store_item"] = StoreItem.get_cheapest_store_item(Product.where.not(food: nil).search(list_item.items.last.name).first.food, merchant)
      end
      merchant_products << dic
    end
    return merchant_products
  end

  def self.get_cheapest_store_item(food, store)
    cheapest_store_item = food.store_items.where(store: store).pluck(:price, :id, :is_available).reject {|x| x.first < 0.02 || x[2] == false }.min
    cheapest_store_item = StoreItem.find(cheapest_store_item.second) if cheapest_store_item.present?
    return cheapest_store_item
  end

  def imported
    self.is_imported = true
    self.save
  end

  def not_imported
    self.is_imported = false
    self.save
  end



  def self.get_results_sorted_by_price(item, store)
    # return list of store items sorted by price
    data = []

    search_queries = []
    # search products with item.food and merchant
    search_queries << Product.search(item.name,
                            fields: [:name, :brand],
                            where:  {stores: store.name,
                                    food_id: item.food.id}, execute: false) if item.food.present?

    # else search food name and get related products
    search_queries << Food.search(item.name, execute: false) if item.food.present?

    # elsif item has food but no results, search products based on name only
    search_queries << Product.search(item.name,
                            fields: [:name, :brand],
                            where:  {stores: store.name}, execute: false)

    Searchkick.multi_search(search_queries)

    results = search_queries.map{ |search| search.results}.compact.first

    results = results.products if results.present? && results.class.name == "Food"

    # if results, sort results by price and get cheapest one
    if results.present?
      # stop using is_available info for now
      results = results.map{ |result| result.store_items.where(store: store).pluck(:price, :id, :is_available).reject {|x| x.first < 0.02 } }
      results.each{ |result| data << StoreItem.find(result.first.second) if result.any? }
    end


    return data.sort_by{ |r| r.price}

  end




  # Import CSV and update product / items catalog
  def self.import(file)
    catalog = CSV.read(file.path, headers: true)
    ImportCatalogJob.perform_now(catalog)
  end

  def self.update_catalog(catalog)

    Thread.new do
      #1 create or update store items based on new catalog
      catalog.each do |row|

        item = row.to_h
        store = Store.find_by(name: item["store"])
        product = Product.find_by(ean: item["ean"])
        store_item = StoreItem.find_by(product: product, store: store)
        shelters = item["shelter"][1..-2].split("'").reject {|x| x.size < 3}

        # # update leclerc product info with carrefour
        # if store.name == "Carrefour" && product.present? && product.stores.exclude?(store)
        #   product.update(name: item["description"], quantity: item["quantity_match"])
        #   product.brand = item["brand"] if product.brand.nil?
        #   product.origin = item["origin"] if product.origin.nil?
        # end

        if item["ean"] == "0"
          store_item.update(is_available: false) if store_item.present?

        elsif product.nil?
          food = Food.match_food(item["description1"]) if item['description1'].present?
          unit = Unit.search(item['unit_match'], fields: [{name: :exact}], misspellings: {edit_distance: 1}).first if item['unit_match'].present?
          product = Product.find_or_create_by(food: food, ean: item["ean"], name: item["description"], quantity: item["quantity_match"], unit: unit, brand: item["brand"], origin: item["origin"], is_frozen: item["is_frozen"].downcase)
          store_item = StoreItem.create(product: product, store: store, store_product_id: item["product_id"], name: item["description"], price: item["price_match"], price_per_unit: item["price_per_unit_match"], is_promo: false, shelters: shelters, url: item["url"], image_url: item["image_url"], is_available: true) if store_item.nil?

        elsif product.food.nil?
          food = Food.match_food(item["description1"]) if item['description1'].present?
          product.update(food: food)

        elsif store_item.nil?
          store_item = StoreItem.create(product: product, store: store, store_product_id: item["product_id"], name: item["description"], price: item["price_match"], price_per_unit: item["price_per_unit_match"], is_promo: false, shelters: shelters, url: item["url"], image_url: item["image_url"], is_available: true)

        else
          store_item.update(name: item["description"], price: item["price_match"], price_per_unit: item["price_per_unit_match"], is_promo: false, shelters: shelters, url: item["url"], image_url: item["image_url"], is_available: true)
        end


        StoreItemHistory.find_or_create_by(store_item: store_item, price_per_unit: store_item.price_per_unit, is_promo: store_item.is_promo, is_available: store_item.is_available, date: Date.today) if store_item.present?

        puts "#{item["description"]}"

      end

      #2 get list of store items that are not in the new catalog in order to make them unavailable
      store = Store.find_by(name: catalog.first["store"])
      store_items = StoreItem.where(store_id: store.id)

      catalog_eans = []
      catalog.each {|row| catalog_eans << row["ean"] if row["store"] == store.name}

      unavailable_items = store_items - store_items.joins(:product).where(products: {ean: catalog_eans})

      unavailable_items.each do |store_item|
        store_item.update(is_promo: false, is_available: false)
        StoreItemHistory.find_or_create_by(store_item: store_item, price_per_unit: store_item.price_per_unit, is_promo: store_item.is_promo, is_available: store_item.is_available, date: Date.today)
      end

      puts "finished !"
    end
  end

end
