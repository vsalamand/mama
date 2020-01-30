# require 'csv'

# namespace :import do
#   desc "Import new product data from Leclerc catalog CSV"
#   task catalog: :environment do
#     # file_path = Rails.root.join('db', 'product_catalogs', 'leclerc_catalog.csv')
#     catalog = CSV.read(args[:file], headers: true)

#     # mark all available items as not imported so we can make unavailable all items that were not in the new catalog
#     StoreItem.where(is_available: true).update_all(is_imported: false)


#     # create or update store items based on new catalog
#     catalog.each do |row|

#       item = row.to_h
#       puts "#{item["description"]}"

#       store = Store.find_by(name: item["store"])
#       product_name = item["description"]
#       shelters = item["shelter"][1..-2].split("'")

#       product = Product.find_by(ean: item["ean"])


#       store_item = StoreItem.find_by(store_id: store.id, name: product_name)
#       if store_item.nil?
#         store_item = StoreItem.find_by(product_id: product.id, store_id: store.id)
#       end


#       if item["ean"].to_i == 0
#         store_item.update(is_available: false) if store_item.present?
#       elsif product.nil?
#         food = Food.match_food(item["clean_name"]) if item['clean_name'].present?
#         unit = Unit.search(item['unit_match'], fields: [{name: :exact}], misspellings: {edit_distance: 1}).first if item['unit_match'].present?
#         product = Product.create(food: food, ean: item["ean"], name: item["description"], quantity: item["quantity_match"], unit: unit, brand: item["brand"], origin: item["origin"], is_frozen: item["is_frozen"].downcase)
#         store_item = StoreItem.create(product: product, store: store, store_product_id: item["product_id"], clean_name: item["clean_name"], name: item["description"], price: item["price_match"], price_per_unit: item["price_per_unit_match"], is_promo: item["is_promo"].downcase, promo_price_per_unit: item["promo_price_per_unit_match"], shelters: shelters, url: item["url"], image_url: item["image_url"], is_available: true)
#       elsif store_item.nil?
#         store_item = StoreItem.create(product: product, store: store, store_product_id: item["product_id"], clean_name: item["clean_name"], name: item["description"], price: item["price_match"], price_per_unit: item["price_per_unit_match"], is_promo: item["is_promo"].downcase, promo_price_per_unit: item["promo_price_per_unit_match"], shelters: shelters, url: item["url"], image_url: item["image_url"], is_available: item["is_available"].downcase)
#       else
#         store_item.update(name: item["description"], price: item["price_match"], price_per_unit: item["price_per_unit_match"], is_promo: item["is_promo"].downcase, promo_price_per_unit: item["promo_price_per_unit_match"], shelters: shelters, url: item["url"], image_url: item["image_url"], is_available: true)
#       end

#       store_item.imported
#       StoreItemHistory.find_or_create_by(store_item: store_item, price_per_unit: store_item.price_per_unit, is_promo: store_item.is_promo, is_available: store_item.is_available, date: Date.today) if store_item.present?

#     end

#     # make old items not in the new catalog unavailable
#     StoreItem.where(is_available: true).where(is_imported: false).each do |store_item|
#       store_item.update(is_promo: false, is_available: false)
#       StoreItemHistory.find_or_create_by(store_item: store_item, price_per_unit: store_item.price_per_unit, is_promo: store_item.is_promo, is_available: store_item.is_available, date: Date.today)
#       puts "Now unavailable: #{store_item["name"]}"
#     end

#   end
# end

# ## hotfix script to update products and store items in production if import is messed up
#     # file_path = Rails.root.join('db', 'product_catalogs', 'leclerc_catalog.csv')
#     # catalog = CSV.read(file_path, headers: true)
#     # store = Store.first
#     # catalog.each do |row|
#     #   item = row.to_h
#     #   product = Product.find_by(ean: item["ean"])
#     #   store_item = StoreItem.find_by(product: product, store: store)
#     #   store_item.update(clean_name: item["clean_name"])
#     #   food = Food.match_food(item["clean_name"]) if item['clean_name'].present?
#     #   product.update(food: food)
#     #   puts "#{item["description"]}"
#     # end


# ## hotfix script to delete duplicates in DB
# # duplicate_values = Product.group(:ean).having(Product.arel_table[:ean].count.gt(1)).count.keys
# # duplicate_values.each{ |product_ean| Product.where(ean: product_ean).last.destroy }

# # duplicate_values = StoreItem.where(store:2).group(:name).having(StoreItem.arel_table[:name].count.gt(1)).count.keys
# # duplicate_values.each{ |name| StoreItem.where(store: 2, name: name).last.destroy }


