ActiveRecord::Schema.define(:version => 20090317164830) do
  create_table "androids", :force => true do |t|
    t.string   "name"
    t.integer  "owner_id"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "people", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "components", :force => true do |t|
    t.string   "name"
    t.integer  "android_id"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ninjas", :force => true do |t|
    t.string   "name"
    t.boolean  "visible", :default => false
  end

  create_table "pirates", :force => true do |t|
    t.string   "name"
    t.boolean  "alive", :default => true
  end
end