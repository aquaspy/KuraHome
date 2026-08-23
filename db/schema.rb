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

ActiveRecord::Schema[8.1].define(version: 2026_08_23_190000) do
  create_table "profiles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.integer "position", default: 0, null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id", "position"], name: "index_profiles_on_user_id_and_position"
    t.index ["user_id"], name: "index_profiles_on_user_id"
  end

  create_table "sites", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "hint", default: "", null: false
    t.string "icon_url", default: "", null: false
    t.integer "position", default: 0, null: false
    t.integer "profile_id", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.string "url", null: false
    t.index ["profile_id", "position"], name: "index_sites_on_profile_id_and_position"
    t.index ["profile_id"], name: "index_sites_on_profile_id"
  end

  create_table "stack_items", force: :cascade do |t|
    t.string "category", null: false
    t.string "choice", null: false
    t.datetime "created_at", null: false
    t.string "icon_url", default: "", null: false
    t.string "note", default: "", null: false
    t.string "origin", default: "", null: false
    t.integer "position", default: 0, null: false
    t.integer "profile_id", null: false
    t.datetime "updated_at", null: false
    t.string "url", default: "", null: false
    t.index ["profile_id", "position"], name: "index_stack_items_on_profile_id_and_position"
    t.index ["profile_id"], name: "index_stack_items_on_profile_id"
  end

  create_table "users", force: :cascade do |t|
    t.boolean "auto_lock", default: false, null: false
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "profiles", "users"
  add_foreign_key "sites", "profiles"
  add_foreign_key "stack_items", "profiles"
end
