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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 201109211852030) do

  create_table "book_stats", :force => true do |t|
    t.string  "book_uid"
    t.integer "total_images"
    t.integer "total_essential_images", :default => 0
    t.integer "total_images_described", :default => 0
    t.string  "book_title"
  end

  create_table "books", :force => true do |t|
    t.string   "uid",                                          :null => false
    t.string   "title"
    t.string   "isbn",       :limit => 13
    t.integer  "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "xml_file",                 :default => "none", :null => false
  end

  add_index "books", ["isbn"], :name => "index_books_on_isbn"
  add_index "books", ["title"], :name => "index_books_on_title"
  add_index "books", ["uid"], :name => "index_books_on_uid"

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.text     "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "descriptions", :force => true do |t|
    t.string   "description",   :limit => 16384,                          :null => false
    t.boolean  "is_current",                     :default => false
    t.string   "submitter",                      :default => "anonymous", :null => false
    t.datetime "date_approved"
    t.integer  "image_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "descriptions", ["image_id"], :name => "fk_descriptions_image"

  create_table "dynamic_descriptions", :force => true do |t|
    t.string   "body",             :limit => 16384,                          :null => false
    t.boolean  "is_current",                        :default => false,       :null => false
    t.string   "submitter",                         :default => "anonymous", :null => false
    t.datetime "date_approved"
    t.integer  "dynamic_image_id",                                           :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "book_uid"
  end

  add_index "dynamic_descriptions", ["book_uid", "dynamic_image_id"], :name => "index_dynamic_descriptions_on_book_uid_and_dynamic_image_id"
  add_index "dynamic_descriptions", ["dynamic_image_id"], :name => "index_dynamic_descriptions_on_dynamic_image_id"

  create_table "dynamic_images", :force => true do |t|
    t.string   "book_uid",            :null => false
    t.string   "book_title"
    t.string   "image_location",      :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "should_be_described"
    t.integer  "width"
    t.integer  "height"
    t.string   "xml_id"
  end

  add_index "dynamic_images", ["book_uid", "image_location"], :name => "index_dynamic_images_on_book_uid_and_image_location"
  add_index "dynamic_images", ["book_uid", "should_be_described"], :name => "index_dynamic_images_on_book_uid_and_should_be_described"

  create_table "images", :force => true do |t|
    t.integer  "book_id",                         :null => false
    t.string   "image_id",                        :null => false
    t.string   "isbn",            :limit => 13
    t.integer  "page_number"
    t.integer  "sequence_number"
    t.string   "caption",         :limit => 8192
    t.string   "url"
    t.integer  "library_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "images", ["library_id", "book_id", "image_id"], :name => "images_book_image_unq", :unique => true
  add_index "images", ["library_id"], :name => "fk_images_library"

  create_table "libraries", :force => true do |t|
    t.string   "name",       :limit => 128, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "libraries", ["name"], :name => "name", :unique => true

  create_table "users", :force => true do |t|
    t.string   "email",                                 :default => "", :null => false
    t.string   "encrypted_password",     :limit => 128, :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                         :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "username",                                              :null => false
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  add_index "users", ["username"], :name => "index_users_on_username", :unique => true

end
