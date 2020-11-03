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

ActiveRecord::Schema.define(version: 2020_11_02_210727) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "game_game_modes", force: :cascade do |t|
    t.bigint "game_id", null: false
    t.bigint "game_mode_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["game_id"], name: "index_game_game_modes_on_game_id"
    t.index ["game_mode_id"], name: "index_game_game_modes_on_game_mode_id"
  end

  create_table "game_genres", force: :cascade do |t|
    t.bigint "genre_id", null: false
    t.bigint "game_id", null: false
    t.index ["game_id"], name: "index_game_genres_on_game_id"
    t.index ["genre_id"], name: "index_game_genres_on_genre_id"
  end

  create_table "game_keywords", force: :cascade do |t|
    t.bigint "game_id", null: false
    t.bigint "keyword_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["game_id"], name: "index_game_keywords_on_game_id"
    t.index ["keyword_id"], name: "index_game_keywords_on_keyword_id"
  end

  create_table "game_modes", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "game_multiplayer_modes", force: :cascade do |t|
    t.bigint "game_id", null: false
    t.bigint "multiplayer_mode_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "min"
    t.integer "max"
    t.index ["game_id"], name: "index_game_multiplayer_modes_on_game_id"
    t.index ["multiplayer_mode_id"], name: "index_game_multiplayer_modes_on_multiplayer_mode_id"
  end

  create_table "game_themes", force: :cascade do |t|
    t.bigint "game_id", null: false
    t.bigint "theme_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["game_id"], name: "index_game_themes_on_game_id"
    t.index ["theme_id"], name: "index_game_themes_on_theme_id"
  end

  create_table "games", force: :cascade do |t|
    t.integer "igdb_id"
    t.string "name"
    t.string "cover_url"
    t.string "release_date"
    t.string "platforms"
    t.string "storyline"
    t.string "summary"
    t.float "total_rating"
    t.string "involved_companies"
    t.string "game_profile"
  end

  create_table "genres", force: :cascade do |t|
    t.string "name"
  end

  create_table "keywords", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "multiplayer_modes", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "themes", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "user_games", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "game_id", null: false
    t.string "list"
    t.index ["game_id"], name: "index_user_games_on_game_id"
    t.index ["user_id"], name: "index_user_games_on_user_id"
  end

  create_table "user_played_games", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "game_id", null: false
    t.integer "liked"
    t.index ["game_id"], name: "index_user_played_games_on_game_id"
    t.index ["user_id"], name: "index_user_played_games_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "password_digest"
    t.string "steam_name"
    t.string "steam_id"
  end

  add_foreign_key "game_game_modes", "game_modes"
  add_foreign_key "game_game_modes", "games"
  add_foreign_key "game_genres", "games"
  add_foreign_key "game_genres", "genres"
  add_foreign_key "game_keywords", "games"
  add_foreign_key "game_keywords", "keywords"
  add_foreign_key "game_multiplayer_modes", "games"
  add_foreign_key "game_multiplayer_modes", "multiplayer_modes"
  add_foreign_key "game_themes", "games"
  add_foreign_key "game_themes", "themes"
  add_foreign_key "user_games", "games"
  add_foreign_key "user_games", "users"
  add_foreign_key "user_played_games", "games"
  add_foreign_key "user_played_games", "users"
end
