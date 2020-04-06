# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20200405142419) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "pg_stat_statements"

  create_table "ahoy_events", force: :cascade do |t|
    t.integer  "visit_id"
    t.integer  "user_id"
    t.string   "name"
    t.jsonb    "properties"
    t.datetime "time"
    t.index "properties jsonb_path_ops", name: "index_ahoy_events_on_properties_jsonb_path_ops", using: :gin
    t.index ["name", "time"], name: "index_ahoy_events_on_name_and_time", using: :btree
    t.index ["user_id"], name: "index_ahoy_events_on_user_id", using: :btree
    t.index ["visit_id"], name: "index_ahoy_events_on_visit_id", using: :btree
  end

  create_table "ahoy_visits", force: :cascade do |t|
    t.string   "visit_token"
    t.string   "visitor_token"
    t.integer  "user_id"
    t.string   "ip"
    t.text     "user_agent"
    t.text     "referrer"
    t.string   "referring_domain"
    t.text     "landing_page"
    t.string   "browser"
    t.string   "os"
    t.string   "device_type"
    t.string   "country"
    t.string   "region"
    t.string   "city"
    t.string   "utm_source"
    t.string   "utm_medium"
    t.string   "utm_term"
    t.string   "utm_content"
    t.string   "utm_campaign"
    t.string   "app_version"
    t.string   "os_version"
    t.string   "platform"
    t.datetime "started_at"
    t.index ["user_id"], name: "index_ahoy_visits_on_user_id", using: :btree
    t.index ["visit_token"], name: "index_ahoy_visits_on_visit_token", unique: true, using: :btree
  end

  create_table "banned_categories", force: :cascade do |t|
    t.string   "name"
    t.integer  "category_id"
    t.integer  "diet_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["category_id"], name: "index_banned_categories_on_category_id", using: :btree
    t.index ["diet_id"], name: "index_banned_categories_on_diet_id", using: :btree
  end

  create_table "banned_foods", force: :cascade do |t|
    t.string   "name"
    t.integer  "diet_id"
    t.integer  "food_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["diet_id"], name: "index_banned_foods_on_diet_id", using: :btree
    t.index ["food_id"], name: "index_banned_foods_on_food_id", using: :btree
  end

  create_table "blazer_audits", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "query_id"
    t.text     "statement"
    t.string   "data_source"
    t.datetime "created_at"
    t.index ["query_id"], name: "index_blazer_audits_on_query_id", using: :btree
    t.index ["user_id"], name: "index_blazer_audits_on_user_id", using: :btree
  end

  create_table "blazer_checks", force: :cascade do |t|
    t.integer  "creator_id"
    t.integer  "query_id"
    t.string   "state"
    t.string   "schedule"
    t.text     "emails"
    t.text     "slack_channels"
    t.string   "check_type"
    t.text     "message"
    t.datetime "last_run_at"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.index ["creator_id"], name: "index_blazer_checks_on_creator_id", using: :btree
    t.index ["query_id"], name: "index_blazer_checks_on_query_id", using: :btree
  end

  create_table "blazer_dashboard_queries", force: :cascade do |t|
    t.integer  "dashboard_id"
    t.integer  "query_id"
    t.integer  "position"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.index ["dashboard_id"], name: "index_blazer_dashboard_queries_on_dashboard_id", using: :btree
    t.index ["query_id"], name: "index_blazer_dashboard_queries_on_query_id", using: :btree
  end

  create_table "blazer_dashboards", force: :cascade do |t|
    t.integer  "creator_id"
    t.text     "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_blazer_dashboards_on_creator_id", using: :btree
  end

  create_table "blazer_queries", force: :cascade do |t|
    t.integer  "creator_id"
    t.string   "name"
    t.text     "description"
    t.text     "statement"
    t.string   "data_source"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["creator_id"], name: "index_blazer_queries_on_creator_id", using: :btree
  end

  create_table "cart_items", force: :cascade do |t|
    t.string   "name"
    t.string   "productable_type"
    t.integer  "productable_id"
    t.integer  "quantity"
    t.integer  "cart_id"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.integer  "order_id"
    t.integer  "item_id"
    t.index ["cart_id"], name: "index_cart_items_on_cart_id", using: :btree
    t.index ["item_id"], name: "index_cart_items_on_item_id", using: :btree
    t.index ["order_id"], name: "index_cart_items_on_order_id", using: :btree
    t.index ["productable_type", "productable_id"], name: "index_cart_items_on_productable_type_and_productable_id", using: :btree
  end

  create_table "carts", force: :cascade do |t|
    t.integer  "user_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "size"
    t.integer  "merchant_id"
    t.index ["merchant_id"], name: "index_carts_on_merchant_id", using: :btree
    t.index ["user_id"], name: "index_carts_on_user_id", using: :btree
  end

  create_table "categories", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "ancestry"
    t.string   "rating"
    t.index ["ancestry"], name: "index_categories_on_ancestry", using: :btree
  end

  create_table "checklist_items", force: :cascade do |t|
    t.string   "name"
    t.integer  "checklist_id"
    t.integer  "list_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.index ["checklist_id"], name: "index_checklist_items_on_checklist_id", using: :btree
    t.index ["list_id"], name: "index_checklist_items_on_list_id", using: :btree
  end

  create_table "checklists", force: :cascade do |t|
    t.string   "name"
    t.string   "schedule"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "diet_id"
    t.index ["diet_id"], name: "index_checklists_on_diet_id", using: :btree
  end

  create_table "collaborations", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "list_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["list_id"], name: "index_collaborations_on_list_id", using: :btree
    t.index ["user_id"], name: "index_collaborations_on_user_id", using: :btree
  end

  create_table "diets", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.boolean  "is_active"
  end

  create_table "food_list_items", force: :cascade do |t|
    t.string   "name"
    t.integer  "food_id"
    t.integer  "food_list_id"
    t.integer  "checklist_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.index ["checklist_id"], name: "index_food_list_items_on_checklist_id", using: :btree
    t.index ["food_id"], name: "index_food_list_items_on_food_id", using: :btree
    t.index ["food_list_id"], name: "index_food_list_items_on_food_list_id", using: :btree
  end

  create_table "food_lists", force: :cascade do |t|
    t.string   "name"
    t.integer  "user_id"
    t.text     "description"
    t.string   "food_list_type"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.integer  "diet_id"
    t.index ["diet_id"], name: "index_food_lists_on_diet_id", using: :btree
    t.index ["user_id"], name: "index_food_lists_on_user_id", using: :btree
  end

  create_table "foods", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at",                                                                null: false
    t.datetime "updated_at",                                                                null: false
    t.string   "availability",   default: "01, 02, 03, 04, 05, 06, 07, 08, 09, 10, 11, 12"
    t.integer  "category_id"
    t.string   "ancestry"
    t.string   "measure"
    t.float    "serving"
    t.float    "unit_per_piece"
    t.integer  "unit_id"
    t.index ["ancestry"], name: "index_foods_on_ancestry", using: :btree
    t.index ["category_id"], name: "index_foods_on_category_id", using: :btree
    t.index ["unit_id"], name: "index_foods_on_unit_id", using: :btree
  end

  create_table "items", force: :cascade do |t|
    t.integer  "food_id"
    t.integer  "recipe_id"
    t.integer  "unit_id"
    t.float    "quantity"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.string   "name"
    t.integer  "list_item_id"
    t.boolean  "is_validated", default: false
    t.boolean  "is_non_food",  default: false, null: false
    t.index ["food_id"], name: "index_items_on_food_id", using: :btree
    t.index ["list_item_id"], name: "index_items_on_list_item_id", using: :btree
    t.index ["recipe_id"], name: "index_items_on_recipe_id", using: :btree
    t.index ["unit_id"], name: "index_items_on_unit_id", using: :btree
  end

  create_table "list_items", force: :cascade do |t|
    t.string   "name"
    t.integer  "list_id"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.boolean  "deleted",      default: false
    t.boolean  "is_completed", default: false
    t.integer  "position"
    t.index ["list_id"], name: "index_list_items_on_list_id", using: :btree
  end

  create_table "lists", force: :cascade do |t|
    t.string   "name"
    t.integer  "user_id"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.string   "status",     default: "archived"
    t.boolean  "is_deleted", default: false
    t.string   "list_type",  default: "personal"
    t.string   "sorted_by"
    t.index ["user_id"], name: "index_lists_on_user_id", using: :btree
  end

  create_table "merchants", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "meta_recipe_items", force: :cascade do |t|
    t.integer  "meta_recipe_id"
    t.integer  "food_id"
    t.string   "ingredient"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.string   "name"
    t.integer  "unit_id"
    t.float    "quantity"
    t.index ["food_id"], name: "index_meta_recipe_items_on_food_id", using: :btree
    t.index ["meta_recipe_id"], name: "index_meta_recipe_items_on_meta_recipe_id", using: :btree
    t.index ["unit_id"], name: "index_meta_recipe_items_on_unit_id", using: :btree
  end

  create_table "meta_recipe_list_items", force: :cascade do |t|
    t.integer  "meta_recipe_list_id"
    t.integer  "meta_recipe_id"
    t.string   "name"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.index ["meta_recipe_id"], name: "index_meta_recipe_list_items_on_meta_recipe_id", using: :btree
    t.index ["meta_recipe_list_id"], name: "index_meta_recipe_list_items_on_meta_recipe_list_id", using: :btree
  end

  create_table "meta_recipe_lists", force: :cascade do |t|
    t.string   "name"
    t.integer  "recipe_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "list_type"
    t.string   "link"
    t.string   "author"
    t.index ["recipe_id"], name: "index_meta_recipe_lists_on_recipe_id", using: :btree
  end

  create_table "meta_recipes", force: :cascade do |t|
    t.string   "name"
    t.integer  "servings",     default: 1
    t.text     "ingredients"
    t.text     "instructions"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.string   "meta_type"
  end

  create_table "orders", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "cart_id"
    t.string   "order_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "context"
    t.index ["cart_id"], name: "index_orders_on_cart_id", using: :btree
    t.index ["user_id"], name: "index_orders_on_user_id", using: :btree
  end

  create_table "products", force: :cascade do |t|
    t.integer  "food_id"
    t.string   "ean"
    t.string   "name"
    t.float    "quantity"
    t.integer  "unit_id"
    t.string   "brand"
    t.string   "origin"
    t.boolean  "is_frozen"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.boolean  "is_reported", default: false
    t.index ["food_id"], name: "index_products_on_food_id", using: :btree
    t.index ["unit_id"], name: "index_products_on_unit_id", using: :btree
  end

  create_table "recipe_list_items", force: :cascade do |t|
    t.integer  "recipe_id"
    t.integer  "recipe_list_id"
    t.integer  "position"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.string   "name"
    t.index ["recipe_id"], name: "index_recipe_list_items_on_recipe_id", using: :btree
    t.index ["recipe_list_id"], name: "index_recipe_list_items_on_recipe_list_id", using: :btree
  end

  create_table "recipe_lists", force: :cascade do |t|
    t.string   "name"
    t.integer  "user_id"
    t.text     "description"
    t.string   "recipe_list_type"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.string   "status",           default: "archived"
    t.index ["user_id"], name: "index_recipe_lists_on_user_id", using: :btree
  end

  create_table "recipes", force: :cascade do |t|
    t.string   "title"
    t.string   "servings"
    t.text     "ingredients"
    t.text     "instructions"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.boolean  "recommendable"
    t.string   "status"
    t.string   "origin"
    t.string   "link"
    t.string   "rating"
    t.string   "image_url"
  end

  create_table "recommendation_items", force: :cascade do |t|
    t.string   "name"
    t.integer  "recommendation_id"
    t.integer  "recipe_list_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.index ["recipe_list_id"], name: "index_recommendation_items_on_recipe_list_id", using: :btree
    t.index ["recommendation_id"], name: "index_recommendation_items_on_recommendation_id", using: :btree
  end

  create_table "recommendations", force: :cascade do |t|
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.string   "name"
    t.datetime "date"
    t.text     "description"
    t.string   "image_url"
    t.string   "link"
    t.integer  "user_id"
    t.boolean  "is_active",   default: false
    t.index ["user_id"], name: "index_recommendations_on_user_id", using: :btree
  end

  create_table "store_cart_items", force: :cascade do |t|
    t.integer  "store_cart_id"
    t.integer  "store_item_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "item_id"
    t.index ["item_id"], name: "index_store_cart_items_on_item_id", using: :btree
    t.index ["store_cart_id"], name: "index_store_cart_items_on_store_cart_id", using: :btree
    t.index ["store_item_id"], name: "index_store_cart_items_on_store_item_id", using: :btree
  end

  create_table "store_carts", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "store_id"
    t.integer  "list_id"
    t.integer  "recipe_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["list_id"], name: "index_store_carts_on_list_id", using: :btree
    t.index ["recipe_id"], name: "index_store_carts_on_recipe_id", using: :btree
    t.index ["store_id"], name: "index_store_carts_on_store_id", using: :btree
    t.index ["user_id"], name: "index_store_carts_on_user_id", using: :btree
  end

  create_table "store_item_histories", force: :cascade do |t|
    t.integer  "store_item_id"
    t.float    "price_per_unit"
    t.boolean  "is_promo"
    t.boolean  "is_available"
    t.date     "date"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.index ["store_item_id"], name: "index_store_item_histories_on_store_item_id", using: :btree
  end

  create_table "store_items", force: :cascade do |t|
    t.integer  "product_id"
    t.integer  "store_id"
    t.integer  "store_product_id"
    t.string   "clean_name"
    t.string   "name"
    t.float    "price"
    t.float    "price_per_unit"
    t.boolean  "is_promo"
    t.float    "promo_price_per_unit"
    t.string   "url"
    t.string   "image_url"
    t.boolean  "is_available"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.text     "shelters",             default: [],              array: true
    t.index ["product_id"], name: "index_store_items_on_product_id", using: :btree
    t.index ["store_id"], name: "index_store_items_on_store_id", using: :btree
  end

  create_table "stores", force: :cascade do |t|
    t.string   "name"
    t.string   "store_type"
    t.integer  "merchant_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["merchant_id"], name: "index_stores_on_merchant_id", using: :btree
  end

  create_table "taggings", force: :cascade do |t|
    t.integer  "tag_id"
    t.string   "taggable_type"
    t.integer  "taggable_id"
    t.string   "tagger_type"
    t.integer  "tagger_id"
    t.string   "context",       limit: 128
    t.datetime "created_at"
    t.index ["context"], name: "index_taggings_on_context", using: :btree
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true, using: :btree
    t.index ["tag_id"], name: "index_taggings_on_tag_id", using: :btree
    t.index ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context", using: :btree
    t.index ["taggable_id", "taggable_type", "tagger_id", "context"], name: "taggings_idy", using: :btree
    t.index ["taggable_id"], name: "index_taggings_on_taggable_id", using: :btree
    t.index ["taggable_type"], name: "index_taggings_on_taggable_type", using: :btree
    t.index ["tagger_id", "tagger_type"], name: "index_taggings_on_tagger_id_and_tagger_type", using: :btree
    t.index ["tagger_id"], name: "index_taggings_on_tagger_id", using: :btree
  end

  create_table "tags", force: :cascade do |t|
    t.string  "name"
    t.integer "taggings_count", default: 0
    t.index ["name"], name: "index_tags_on_name", unique: true, using: :btree
  end

  create_table "units", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.boolean  "admin",                  default: false, null: false
    t.boolean  "beta",                   default: false
    t.string   "sender_id"
    t.string   "username"
    t.integer  "diet_id"
    t.index ["diet_id"], name: "index_users_on_diet_id", using: :btree
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

  add_foreign_key "banned_categories", "categories"
  add_foreign_key "banned_categories", "diets"
  add_foreign_key "banned_foods", "diets"
  add_foreign_key "banned_foods", "foods"
  add_foreign_key "cart_items", "carts"
  add_foreign_key "cart_items", "items"
  add_foreign_key "cart_items", "orders", on_delete: :cascade
  add_foreign_key "carts", "merchants"
  add_foreign_key "carts", "users"
  add_foreign_key "checklist_items", "checklists"
  add_foreign_key "checklist_items", "lists"
  add_foreign_key "checklists", "diets"
  add_foreign_key "collaborations", "lists"
  add_foreign_key "collaborations", "users"
  add_foreign_key "food_list_items", "checklists"
  add_foreign_key "food_list_items", "food_lists"
  add_foreign_key "food_list_items", "foods"
  add_foreign_key "food_lists", "diets"
  add_foreign_key "food_lists", "users"
  add_foreign_key "foods", "categories"
  add_foreign_key "foods", "units"
  add_foreign_key "items", "foods"
  add_foreign_key "items", "list_items"
  add_foreign_key "items", "recipes"
  add_foreign_key "items", "units"
  add_foreign_key "list_items", "lists"
  add_foreign_key "lists", "users"
  add_foreign_key "meta_recipe_items", "foods"
  add_foreign_key "meta_recipe_items", "meta_recipes"
  add_foreign_key "meta_recipe_items", "units"
  add_foreign_key "meta_recipe_list_items", "meta_recipe_lists"
  add_foreign_key "meta_recipe_list_items", "meta_recipes"
  add_foreign_key "meta_recipe_lists", "recipes"
  add_foreign_key "orders", "carts", on_delete: :cascade
  add_foreign_key "orders", "users"
  add_foreign_key "products", "foods"
  add_foreign_key "products", "units"
  add_foreign_key "recipe_list_items", "recipe_lists"
  add_foreign_key "recipe_list_items", "recipes"
  add_foreign_key "recipe_lists", "users"
  add_foreign_key "recommendation_items", "recipe_lists"
  add_foreign_key "recommendation_items", "recommendations"
  add_foreign_key "recommendations", "users"
  add_foreign_key "store_cart_items", "items"
  add_foreign_key "store_cart_items", "store_carts"
  add_foreign_key "store_cart_items", "store_items"
  add_foreign_key "store_carts", "lists"
  add_foreign_key "store_carts", "recipes"
  add_foreign_key "store_carts", "stores"
  add_foreign_key "store_carts", "users"
  add_foreign_key "store_item_histories", "store_items"
  add_foreign_key "store_items", "products"
  add_foreign_key "store_items", "stores"
  add_foreign_key "stores", "merchants"
  add_foreign_key "users", "diets"
end
