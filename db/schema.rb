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

ActiveRecord::Schema.define(version: 20180914132229) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "pg_stat_statements"

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

  create_table "cart_items", force: :cascade do |t|
    t.string   "name"
    t.string   "productable_type"
    t.integer  "productable_id"
    t.integer  "quantity"
    t.integer  "cart_id"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.integer  "order_id"
    t.index ["cart_id"], name: "index_cart_items_on_cart_id", using: :btree
    t.index ["order_id"], name: "index_cart_items_on_order_id", using: :btree
    t.index ["productable_type", "productable_id"], name: "index_cart_items_on_productable_type_and_productable_id", using: :btree
  end

  create_table "carts", force: :cascade do |t|
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "size"
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

  create_table "checklists", force: :cascade do |t|
    t.string   "name"
    t.string   "schedule"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "diet_id"
    t.index ["diet_id"], name: "index_checklists_on_diet_id", using: :btree
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
    t.datetime "created_at",                                                              null: false
    t.datetime "updated_at",                                                              null: false
    t.string   "availability", default: "01, 02, 03, 04, 05, 06, 07, 08, 09, 10, 11, 12"
    t.integer  "category_id"
    t.string   "ancestry"
    t.index ["ancestry"], name: "index_foods_on_ancestry", using: :btree
    t.index ["category_id"], name: "index_foods_on_category_id", using: :btree
  end

  create_table "items", force: :cascade do |t|
    t.integer  "food_id"
    t.integer  "recipe_id"
    t.integer  "unit_id"
    t.float    "quantity"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.string   "recipe_ingredient"
    t.index ["food_id"], name: "index_items_on_food_id", using: :btree
    t.index ["recipe_id"], name: "index_items_on_recipe_id", using: :btree
    t.index ["unit_id"], name: "index_items_on_unit_id", using: :btree
  end

  create_table "orders", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "cart_id"
    t.string   "order_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cart_id"], name: "index_orders_on_cart_id", using: :btree
    t.index ["user_id"], name: "index_orders_on_user_id", using: :btree
  end

  create_table "recipe_list_items", force: :cascade do |t|
    t.integer  "recipe_id"
    t.integer  "recipe_list_id"
    t.integer  "position"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.string   "name"
    t.integer  "recommendation_id"
    t.index ["recipe_id"], name: "index_recipe_list_items_on_recipe_id", using: :btree
    t.index ["recipe_list_id"], name: "index_recipe_list_items_on_recipe_list_id", using: :btree
    t.index ["recommendation_id"], name: "index_recipe_list_items_on_recommendation_id", using: :btree
  end

  create_table "recipe_lists", force: :cascade do |t|
    t.string   "name"
    t.integer  "user_id"
    t.text     "description"
    t.string   "recipe_list_type"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.integer  "diet_id"
    t.index ["diet_id"], name: "index_recipe_lists_on_diet_id", using: :btree
    t.index ["user_id"], name: "index_recipe_lists_on_user_id", using: :btree
  end

  create_table "recipes", force: :cascade do |t|
    t.string   "title"
    t.integer  "servings"
    t.text     "ingredients"
    t.text     "instructions"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.boolean  "recommendable"
    t.string   "status"
    t.string   "origin"
    t.string   "link"
    t.string   "rating"
  end

  create_table "recommendations", force: :cascade do |t|
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.string   "recommendation_type"
    t.string   "schedule"
    t.string   "name"
    t.integer  "diet_id"
    t.index ["diet_id"], name: "index_recommendations_on_diet_id", using: :btree
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
  add_foreign_key "cart_items", "orders", on_delete: :cascade
  add_foreign_key "carts", "users"
  add_foreign_key "checklists", "diets"
  add_foreign_key "food_list_items", "checklists"
  add_foreign_key "food_list_items", "food_lists"
  add_foreign_key "food_list_items", "foods"
  add_foreign_key "food_lists", "diets"
  add_foreign_key "food_lists", "users"
  add_foreign_key "foods", "categories"
  add_foreign_key "items", "foods"
  add_foreign_key "items", "recipes"
  add_foreign_key "items", "units"
  add_foreign_key "orders", "carts", on_delete: :cascade
  add_foreign_key "orders", "users"
  add_foreign_key "recipe_list_items", "recipe_lists"
  add_foreign_key "recipe_list_items", "recipes"
  add_foreign_key "recipe_list_items", "recommendations"
  add_foreign_key "recipe_lists", "diets"
  add_foreign_key "recipe_lists", "users"
  add_foreign_key "recommendations", "diets"
  add_foreign_key "users", "diets"
end
