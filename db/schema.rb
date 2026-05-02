# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2026_05_02_085219) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_stat_statements"
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "color"
  end

  create_table "color_palette_items", force: :cascade do |t|
    t.bigint "color_palette_id", null: false
    t.bigint "ral_id", null: false
    t.bigint "finish_id"
    t.boolean "paid_option", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["color_palette_id", "ral_id", "finish_id"], name: "idx_cpi_palette_ral_finish_uniq", unique: true, where: "(finish_id IS NOT NULL)"
    t.index ["color_palette_id", "ral_id"], name: "idx_cpi_palette_ral_no_finish_uniq", unique: true, where: "(finish_id IS NULL)"
    t.index ["color_palette_id"], name: "index_color_palette_items_on_color_palette_id"
    t.index ["finish_id"], name: "index_color_palette_items_on_finish_id"
    t.index ["ral_id"], name: "index_color_palette_items_on_ral_id"
  end

  create_table "color_palettes", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "events", force: :cascade do |t|
    t.datetime "start_date"
    t.datetime "end_date"
    t.string "title"
    t.string "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "finishes", force: :cascade do |t|
    t.string "code", null: false
    t.string "label", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_finishes_on_code", unique: true
  end

  create_table "manufacturers", force: :cascade do |t|
    t.string "name"
    t.string "logo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "manufacturers_products", id: false, force: :cascade do |t|
    t.bigint "manufacturer_id", null: false
    t.bigint "product_id", null: false
  end

  create_table "motorists", force: :cascade do |t|
    t.string "name"
    t.string "logo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "motorists_products", id: false, force: :cascade do |t|
    t.bigint "motorist_id", null: false
    t.bigint "product_id", null: false
    t.index ["motorist_id"], name: "index_motorists_products_on_motorist_id"
    t.index ["product_id"], name: "index_motorists_products_on_product_id"
  end

  create_table "options", force: :cascade do |t|
    t.string "content"
    t.bigint "product_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "order"
    t.index ["product_id"], name: "index_options_on_product_id"
  end

  create_table "product_color_parts", force: :cascade do |t|
    t.bigint "product_id", null: false
    t.string "code", null: false
    t.string "label", null: false
    t.bigint "color_palette_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["color_palette_id"], name: "index_product_color_parts_on_color_palette_id"
    t.index ["product_id", "code"], name: "idx_product_color_parts_product_code", unique: true
    t.index ["product_id"], name: "index_product_color_parts_on_product_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.bigint "category_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "infos"
    t.string "warranty"
    t.string "type"
    t.string "dimensions"
    t.string "old_price"
    t.string "new_price"
    t.string "slug"
    t.index ["category_id"], name: "index_products_on_category_id"
    t.index ["slug"], name: "index_products_on_slug", unique: true
  end

  create_table "products_rals", id: false, force: :cascade do |t|
    t.bigint "product_id", null: false
    t.bigint "ral_id", null: false
    t.index ["product_id"], name: "index_products_rals_on_product_id"
    t.index ["ral_id"], name: "index_products_rals_on_ral_id"
  end

  create_table "quotes", force: :cascade do |t|
    t.string "lastname"
    t.string "address"
    t.string "city"
    t.string "phone"
    t.string "email"
    t.string "product"
    t.string "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "processed", default: false
  end

  create_table "rals", force: :cascade do |t|
    t.string "name"
    t.string "name_en"
    t.string "ref"
    t.string "rgb"
    t.string "hex"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "collection", default: "classic", null: false
  end

  create_table "services", force: :cascade do |t|
    t.bigint "product_id", null: false
    t.boolean "custom_dimensions"
    t.string "warranty"
    t.boolean "free_quote"
    t.boolean "anti_fire"
    t.boolean "made_in_france"
    t.boolean "anti_uv"
    t.boolean "rge"
    t.boolean "wind_resistance"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_services_on_product_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "color_palette_items", "color_palettes"
  add_foreign_key "color_palette_items", "finishes"
  add_foreign_key "color_palette_items", "rals"
  add_foreign_key "options", "products"
  add_foreign_key "product_color_parts", "color_palettes"
  add_foreign_key "product_color_parts", "products"
  add_foreign_key "products", "categories"
  add_foreign_key "services", "products"
end
