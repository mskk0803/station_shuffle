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

ActiveRecord::Schema[7.2].define(version: 2025_04_20_082145) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "checkins", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.string "station", null: false
  end

  create_table "follow_requests", force: :cascade do |t|
    t.uuid "requester_id", null: false
    t.uuid "requestee_id", null: false
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["requester_id", "requestee_id"], name: "index_follow_requests_on_requester_id_and_requestee_id", unique: true
  end

  create_table "follows", force: :cascade do |t|
    t.uuid "follows_user_id", null: false
    t.uuid "followed_user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["follows_user_id", "followed_user_id"], name: "index_follows_on_follows_user_id_and_followed_user_id", unique: true
  end

  create_table "likes", force: :cascade do |t|
    t.uuid "user_id", null: false
    t.uuid "post_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "post_id"], name: "index_likes_on_user_id_and_post_id", unique: true
  end

  create_table "posts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "image"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "name", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "profile"
    t.boolean "is_private", default: false, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "checkins", "users"
  add_foreign_key "follow_requests", "users", column: "requestee_id"
  add_foreign_key "follow_requests", "users", column: "requester_id"
  add_foreign_key "follows", "users", column: "followed_user_id"
  add_foreign_key "follows", "users", column: "follows_user_id"
  add_foreign_key "likes", "posts"
  add_foreign_key "likes", "users"
  add_foreign_key "posts", "users"
end
