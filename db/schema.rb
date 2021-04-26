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

ActiveRecord::Schema.define(version: 20171020061505) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "categories", force: :cascade do |t|
    t.string   "word"
    t.string   "word_type"
    t.integer  "detected_count"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  create_table "interests", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "social_page_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.index ["social_page_id"], name: "index_interests_on_social_page_id", using: :btree
    t.index ["user_id"], name: "index_interests_on_user_id", using: :btree
  end

  create_table "recommendations", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "social_page_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.index ["social_page_id"], name: "index_recommendations_on_social_page_id", using: :btree
    t.index ["user_id"], name: "index_recommendations_on_user_id", using: :btree
  end

  create_table "relationships", force: :cascade do |t|
    t.integer  "follower_id"
    t.integer  "followed_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["followed_id"], name: "index_relationships_on_followed_id", using: :btree
    t.index ["follower_id", "followed_id"], name: "index_relationships_on_follower_id_and_followed_id", unique: true, using: :btree
    t.index ["follower_id"], name: "index_relationships_on_follower_id", using: :btree
  end

  create_table "relevances", force: :cascade do |t|
    t.integer  "category_id"
    t.integer  "social_page_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.index ["category_id"], name: "index_relevances_on_category_id", using: :btree
    t.index ["social_page_id"], name: "index_relevances_on_social_page_id", using: :btree
  end

  create_table "social_pages", force: :cascade do |t|
    t.string   "page_name"
    t.string   "page_image_url"
    t.integer  "follow_count"
    t.string   "platform_url"
    t.string   "platform_id"
    t.string   "platform_name"
    t.string   "description"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.string   "website"
    t.string   "recent_post_message"
    t.string   "recent_post_url"
    t.string   "recent_post_image_url"
    t.string   "recent_post_video_url"
    t.string   "banner_image_url"
    t.string   "location"
    t.integer  "content_count"
    t.integer  "boards_count"
    t.string   "board_creator"
    t.integer  "main_page_id"
    t.integer  "relevances_id"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.integer  "recent_post_date"
    t.index ["main_page_id"], name: "index_social_pages_on_main_page_id", using: :btree
    t.index ["relevances_id"], name: "index_social_pages_on_relevances_id", using: :btree
  end

  create_table "suggestions", force: :cascade do |t|
    t.integer  "follower_id"
    t.integer  "followed_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["followed_id"], name: "index_suggestions_on_followed_id", using: :btree
    t.index ["follower_id", "followed_id"], name: "index_suggestions_on_follower_id_and_followed_id", unique: true, using: :btree
    t.index ["follower_id"], name: "index_suggestions_on_follower_id", using: :btree
  end

  create_table "topics", force: :cascade do |t|
    t.integer  "category_id"
    t.integer  "user_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["category_id"], name: "index_topics_on_category_id", using: :btree
    t.index ["user_id"], name: "index_topics_on_user_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "facebook_token"
    t.string   "google_token"
    t.string   "pinterest_token"
    t.string   "tumblr_secret"
    t.string   "tumblr_token"
    t.string   "twitter_username"
    t.string   "image"
    t.string   "username"
    t.datetime "created_at",                                               null: false
    t.datetime "updated_at",                                               null: false
    t.string   "provider"
    t.string   "uid"
    t.string   "email",                    default: "",                    null: false
    t.string   "encrypted_password",       default: "",                    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",            default: 0,                     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "facebook_uid"
    t.string   "google_uid"
    t.string   "pinterest_uid"
    t.string   "tumblr_uid"
    t.string   "twitter_uid"
    t.integer  "min_recommendation",       default: 3
    t.integer  "max_recommendation",       default: 10
    t.string   "location"
    t.string   "description"
    t.integer  "recommendations_id"
    t.integer  "topics_id"
    t.string   "favorite_words"
    t.string   "least_favorite_words"
    t.string   "instagram_token"
    t.string   "instagram_uid"
    t.string   "twitch_token"
    t.string   "twitch_uid"
    t.string   "deviantart_token"
    t.string   "deviantart_uid"
    t.string   "spotify_token"
    t.string   "spotify_uid"
    t.string   "reddit_token"
    t.string   "reddit_uid"
    t.boolean  "deviantart_filter",        default: false
    t.boolean  "facebook_filter",          default: false
    t.boolean  "instagram_filter",         default: false
    t.boolean  "pinterest_filter",         default: false
    t.boolean  "reddit_filter",            default: false
    t.boolean  "spotify_filter",           default: false
    t.boolean  "tumblr_filter",            default: false
    t.boolean  "twitter_filter",           default: false
    t.boolean  "twitch_filter",            default: false
    t.boolean  "youtube_filter",           default: false
    t.string   "twitter_token"
    t.string   "twitter_secret"
    t.datetime "last_sync_date"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.boolean  "deviantart_loading",       default: false
    t.boolean  "facebook_loading",         default: false
    t.boolean  "instagram_loading",        default: false
    t.boolean  "pinterest_loading",        default: false
    t.boolean  "reddit_loading",           default: false
    t.boolean  "spotify_loading",          default: false
    t.boolean  "tumblr_loading",           default: false
    t.boolean  "twitter_loading",          default: false
    t.boolean  "twitch_loading",           default: false
    t.boolean  "youtube_loading",          default: false
    t.datetime "facebook_expiry",          default: '2017-11-14 20:48:44'
    t.string   "deviantart_refresh"
    t.string   "unauthorized_accounts",    default: [],                                 array: true
    t.string   "pinterest_username"
    t.string   "reddit_username"
    t.string   "spotify_username"
    t.string   "twitch_username"
    t.string   "youtube_channel_id"
    t.string   "infographic_file_name"
    t.string   "infographic_content_type"
    t.integer  "infographic_file_size"
    t.datetime "infographic_updated_at"
    t.string   "feed_status"
    t.datetime "last_recent_posts_sync",   default: '2017-11-13 20:48:44'
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["recommendations_id"], name: "index_users_on_recommendations_id", using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
    t.index ["topics_id"], name: "index_users_on_topics_id", using: :btree
  end

  create_table "votes", force: :cascade do |t|
    t.string   "votable_type"
    t.integer  "votable_id"
    t.string   "voter_type"
    t.integer  "voter_id"
    t.boolean  "vote_flag"
    t.string   "vote_scope"
    t.integer  "vote_weight"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["votable_id", "votable_type", "vote_scope"], name: "index_votes_on_votable_id_and_votable_type_and_vote_scope", using: :btree
    t.index ["voter_id", "voter_type", "vote_scope"], name: "index_votes_on_voter_id_and_voter_type_and_vote_scope", using: :btree
  end

end
