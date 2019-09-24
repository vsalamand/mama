require 'csv'

namespace :import do
  desc "Import new product data from Leclerc catalog CSV"
  task catalog: :environment do

    file_path = Rails.root.join('db', 'product_catalogs', 'leclerc_catalog.csv')
    catalog = CSV.read(file_path, headers: true)

    catalog.each do |row|

      item = row.to_h
      store = Store.first
      product = Product.find_by(ean: item["ean"])
      store_item = StoreItem.find_by(product: product, store: store)
      shelters = item["shelter"][1..-2].split("'").reject {|x| x.size < 3}

      if product.nil?
        food = Food.match_food(item["clean_description"]) if item['clean_description'].present?
        unit = Unit.search(item['unit_match'], fields: [{name: :exact}], misspellings: {edit_distance: 1}).first if item['unit_match'].present?
        product = Product.create(food: food, ean: item["ean"], name: item["description"], quantity: item["quantity_match"], unit: unit, brand: item["brand"], origin: item["origin"], is_frozen: item["is_frozen"].downcase)
        store_item = StoreItem.create(product: product, store: store, store_product_id: item["product_id"], clean_name: item["clean_description"], name: item["description"], price: item["price_match"], price_per_unit: item["price_per_unit_match"], is_promo: item["is_promo"].downcase, promo_price_per_unit: item["promo_price_per_unit_match"], shelters: shelters, url: item["url"], image_url: item["image_url"], is_available: item["is_available"].downcase)
      elsif store_item.nil?
        store_item = StoreItem.create(product: product, store: store, store_product_id: item["product_id"], clean_name: item["clean_description"], name: item["description"], price: item["price_match"], price_per_unit: item["price_per_unit_match"], is_promo: item["is_promo"].downcase, promo_price_per_unit: item["promo_price_per_unit_match"], shelters: shelters, url: item["url"], image_url: item["image_url"], is_available: item["is_available"].downcase)
      else
        store_item = StoreItem.update(name: item["description"], price: item["price_match"], price_per_unit: item["price_per_unit_match"], is_promo: item["is_promo"].downcase, promo_price_per_unit: item["promo_price_per_unit_match"], shelters: shelters, url: item["url"], image_url: item["image_url"], is_available: item["is_available"].downcase).first
      end

      StoreItemHistory.find_or_create_by(store_item: store_item, price_per_unit: store_item.price_per_unit, is_promo: store_item.is_promo, is_available: store_item.is_available, date: Date.today)

      puts "#{item["description"]}"
    end
  end
end
