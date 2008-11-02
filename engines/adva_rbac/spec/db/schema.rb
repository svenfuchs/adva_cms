ActiveRecord::Schema.define(:version => 0) do
  
  # create_table "accounts", :force => true do |t|
  #   t.string :name
  # end

  create_table "anonymouses", :force => true do |t|
  end

  create_table "boards", :force => true do |t|
    t.integer  "site_id"
    t.integer  "section_id"
  end

  create_table "comments", :force => true do |t|
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.text :permissions
  end

  create_table "contents", :force => true do |t|
    t.integer  "section_id"
    t.text :permissions
  end

  create_table "roles", :force => true do |t|
    t.integer "user_id"
    t.integer "context_id"
    t.string  "context_type"
    t.string  "type",         :limit => 25
  end

  create_table "sections", :force => true do |t|
    t.integer "site_id"
    t.text :permissions
  end

  create_table "sites", :force => true do |t|
    t.integer "account_id"
    t.text :permissions
  end

  create_table "users", :force => true do |t|
    t.integer  :account_id
  end

end
