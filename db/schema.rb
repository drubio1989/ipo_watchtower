# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_10_20_213218) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "api_keys", force: :cascade do |t|
    t.string "access_token"
    t.string "secret_key"
    t.boolean "active", default: true
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["access_token"], name: "index_api_keys_on_access_token"
    t.index ["secret_key"], name: "index_api_keys_on_secret_key"
  end

  create_table "companies", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.string "industry"
    t.integer "employees"
    t.date "founded"
    t.string "address"
    t.string "phone_number"
    t.string "web_address"
    t.string "view_prospectus"
    t.float "market_cap"
    t.float "revenue"
    t.float "net_income"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "slug"
    t.index ["slug"], name: "index_companies_on_slug", unique: true
  end

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string "slug", null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.string "scope"
    t.datetime "created_at"
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_type", "sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_type_and_sluggable_id"
  end

  create_table "industries", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "ipo_profiles", force: :cascade do |t|
    t.string "symbol"
    t.string "exchange"
    t.float "shares"
    t.float "price_low"
    t.float "price_high"
    t.float "estimated_volume"
    t.string "managers"
    t.string "co_managers"
    t.date "expected_to_trade"
    t.string "status"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "company_id"
    t.bigint "industry_id"
    t.float "first_day_close_price"
    t.date "offer_date"
    t.float "current_price"
    t.float "rate_of_return"
    t.date "file_date"
    t.index ["company_id"], name: "index_ipo_profiles_on_company_id"
    t.index ["industry_id"], name: "index_ipo_profiles_on_industry_id"
  end

  add_foreign_key "ipo_profiles", "companies"
  add_foreign_key "ipo_profiles", "industries"
end
