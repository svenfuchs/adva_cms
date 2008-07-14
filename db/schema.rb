# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 0) do

  create_table "activities", :force => true do |t|
    t.integer  "site_id"
    t.integer  "section_id"
    t.integer  "author_id"
    t.string   "author_type"
    t.string   "author_name",       :limit => 40
    t.string   "author_email",      :limit => 40
    t.string   "author_homepage"
    t.string   "actions"
    t.integer  "object_id"
    t.string   "object_type",       :limit => 15
    t.text     "object_attributes"
    t.datetime "created_at",                      :null => false
  end

  create_table "asset_assignments", :force => true do |t|
    t.integer  "content_id"
    t.integer  "asset_id"
    t.string   "label"
    t.datetime "created_at"
    t.boolean  "active"
  end

  create_table "assets", :force => true do |t|
    t.integer  "site_id"
    t.integer  "parent_id"
    t.integer  "user_id"
    t.string   "content_type"
    t.string   "filename"
    t.integer  "size"
    t.string   "thumbnail"
    t.integer  "width"
    t.integer  "height"
    t.string   "title"
    t.integer  "thumbnails_count", :default => 0
    t.datetime "created_at"
  end

  create_table "plugin_configs", :force => true do |t|
    t.integer "site_id"
    t.string  "name"
    t.text    "options"
  end

end
