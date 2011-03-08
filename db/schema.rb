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

ActiveRecord::Schema.define(:version => 20110307204633) do

  create_table "descriptions", :force => true do |t|
    t.string   "description",   :limit => 16384,                          :null => false
    t.boolean  "is_current",                     :default => false
    t.string   "submitter",                      :default => "anonymous", :null => false
    t.datetime "date_approved"
    t.integer  "image_id",                                                :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "descriptions", ["image_id"], :name => "fk_descriptions_image"

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

  add_index "images", ["book_id", "image_id"], :name => "images_book_image_unq", :unique => true
  add_index "images", ["library_id"], :name => "fk_images_library"

  create_table "libraries", :force => true do |t|
    t.string   "name",       :limit => 128, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "libraries", ["name"], :name => "name", :unique => true

end
