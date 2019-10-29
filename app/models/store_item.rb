class StoreItem < ApplicationRecord
  require 'csv'
  require 'rake'


  belongs_to :product
  belongs_to :store
  has_many :store_item_histories, dependent: :destroy
  has_one :food, through: :product
  has_many :cart_items, :as => :productable
  has_one :unit, through: :product

  def get_best_price
    best_price = self.is_promo ? self.price * (self.promo_price_per_unit / self.price_per_unit) : self.price
    return sprintf("%.2f", best_price)
  end

  def self.get_cheap_store_items(list_items)
    cheap_store_items = []
    list_items.each{ |list_item| cheap_store_items << list_item.items.last.food.get_cheapest_store_item if list_item.items.any? && list_item.items.last.food.present? }
    return cheap_store_items.reject(&:blank?)
  end

  # Import CSV and update product / items catalog
  def self.import(file)
    store = Store.first
    catalog = CSV.read(file.path, headers: true)

    Thread.new do

      #1 get list of store items that are not in the new catalog in order to make them unavailable
      catalog_store_ids = []
      catalog.each {|row| catalog_store_ids << row["product_id"]}
      unavailable_items = StoreItem.where(store: store) - StoreItem.where(store_product_id: catalog_store_ids)
      unavailable_items.each do |store_item|
        store_item.update(is_promo: false, is_available: false)
        StoreItemHistory.find_or_create_by(store_item: store_item, price_per_unit: store_item.price_per_unit, is_promo: store_item.is_promo, is_available: store_item.is_available, date: Date.today)
        puts "Now unavailable: #{store_item["name"]}"
      end

      #2 create or update store items based on new catalog
      catalog.each do |row|

        item = row.to_h
        product = Product.find_by(ean: item["ean"])
        store_item = StoreItem.find_by(product: product, store: store)
        shelters = item["shelter"][1..-2].split("'").reject {|x| x.size < 3}

        if item["ean"].to_i == 0
          store_item.update(is_available: false) if store_item.present?
        elsif product.nil?
          food = Food.match_food(item["clean_name"]) if item['clean_name'].present?
          unit = Unit.search(item['unit_match'], fields: [{name: :exact}], misspellings: {edit_distance: 1}).first if item['unit_match'].present?
          product = Product.create(food: food, ean: item["ean"], name: item["description"], quantity: item["quantity_match"], unit: unit, brand: item["brand"], origin: item["origin"], is_frozen: item["is_frozen"].downcase)
          store_item = StoreItem.create(product: product, store: store, store_product_id: item["product_id"], clean_name: item["clean_name"], name: item["description"], price: item["price_match"], price_per_unit: item["price_per_unit_match"], is_promo: item["is_promo"].downcase, promo_price_per_unit: item["promo_price_per_unit_match"], shelters: shelters, url: item["url"], image_url: item["image_url"], is_available: true)
        elsif store_item.nil?
          store_item = StoreItem.create(product: product, store: store, store_product_id: item["product_id"], clean_name: item["clean_name"], name: item["description"], price: item["price_match"], price_per_unit: item["price_per_unit_match"], is_promo: item["is_promo"].downcase, promo_price_per_unit: item["promo_price_per_unit_match"], shelters: shelters, url: item["url"], image_url: item["image_url"], is_available: item["is_available"].downcase)
        else
          store_item.update(name: item["description"], price: item["price_match"], price_per_unit: item["price_per_unit_match"], is_promo: item["is_promo"].downcase, promo_price_per_unit: item["promo_price_per_unit_match"], shelters: shelters, url: item["url"], image_url: item["image_url"], is_available: true)
        end

        StoreItemHistory.find_or_create_by(store_item: store_item, price_per_unit: store_item.price_per_unit, is_promo: store_item.is_promo, is_available: store_item.is_available, date: Date.today) if store_item.present?

        puts "#{item["description"]}"
      end

    end
  end

end
