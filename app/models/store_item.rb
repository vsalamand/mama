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
    catalog = CSV.read(file.path, headers: true)
    ImportCatalogJob.perform_now(catalog)
  end

  def self.update_catalog(catalog)

    #1 get list of store items that are not in the new catalog in order to make them unavailable
    Store.all.each do |store|
      catalog_eans = []
      catalog.each {|row| catalog_eans << row["ean"] if row["store"] == store.name}
      store_items = StoreItem.where(store_id: store.id)
      unavailable_items = store_items - store_items.joins(:product).where(products: {ean: catalog_eans})

      unavailable_items.each do |store_item|
        store_item.update(is_promo: false, is_available: false)
        StoreItemHistory.find_or_create_by(store_item: store_item, price_per_unit: store_item.price_per_unit, is_promo: store_item.is_promo, is_available: store_item.is_available, date: Date.today)
        puts "Now unavailable: #{store_item["description"]}"
      end
    end

    #2 create or update store items based on new catalog
    catalog.each do |row|

      item = row.to_h
      store = Store.find_by(name: row["store"])
      product = Product.find_by(ean: item["ean"])
      store_item = StoreItem.find_by(product: product, store: store)
      shelters = item["shelter"][1..-2].split("'").reject {|x| x.size < 3}

      # update leclerc product info with carrefour
      if store.name == "Carrefour" && product.present? && product.stores.exclude?(store)
        product.update(name: item["description"], quantity: item["quantity_match"])
        product.brand = item["brand"] if product.brand.nil?
        product.origin = item["origin"] if product.origin.nil?
      end

      if item["ean"].to_i == 0
        store_item.update(is_available: false) if store_item.present?
      elsif product.nil?
        food = Food.match_food(item["description1"].downcase) if item['description1'].present?
        unit = Unit.search(item['unit_match'], fields: [{name: :exact}], misspellings: {edit_distance: 1}).first if item['unit_match'].present?
        product = Product.create(food: food, ean: item["ean"], name: item["description"], quantity: item["quantity_match"], unit: unit, brand: item["brand"], origin: item["origin"], is_frozen: item["is_frozen"].downcase)
        store_item = StoreItem.create(product: product, store: store, store_product_id: item["product_id"], name: item["description"], price: item["price_match"], price_per_unit: item["price_per_unit_match"], is_promo: false, shelters: shelters, url: item["url"], image_url: item["image_url"], is_available: true)
      elsif store_item.nil?
        store_item = StoreItem.create(product: product, store: store, store_product_id: item["product_id"], name: item["description"], price: item["price_match"], price_per_unit: item["price_per_unit_match"], is_promo: false, shelters: shelters, url: item["url"], image_url: item["image_url"], is_available: true)
      else
        store_item.update(name: item["description"], price: item["price_match"], price_per_unit: item["price_per_unit_match"], is_promo: false, shelters: shelters, url: item["url"], image_url: item["image_url"], is_available: true)
      end


      StoreItemHistory.find_or_create_by(store_item: store_item, price_per_unit: store_item.price_per_unit, is_promo: store_item.is_promo, is_available: store_item.is_available, date: Date.today) if store_item.present?

      puts "#{item["description"]}"
    end

  end

end
