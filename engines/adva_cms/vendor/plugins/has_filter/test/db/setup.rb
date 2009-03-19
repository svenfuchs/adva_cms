begin
  ActiveRecord::Base.connection 
rescue ActiveRecord::ConnectionNotEstablished => e

  dir_name = File.dirname(__FILE__)
  log_file = "#{dir_name}/../log/test.log"
  db_file  = "#{dir_name}/test.sqlite3.db"
  
  FileUtils.rm(db_file) if File.exists?(db_file)
  FileUtils.mkdir_p(File.dirname(log_file)) unless File.exists?(File.dirname(log_file))

  ActiveRecord::Base.logger = Logger.new log_file
  ActiveRecord::Base.establish_connection :adapter => 'sqlite3', :dbfile => db_file
end

ActiveRecord::Migration.verbose = false
ActiveRecord::Schema.define(:version => 20090126133510) do
  create_table "has_filter_articles", :force => true do |t|
    t.string  :title
    t.string  :body
    t.integer :published
    t.integer :approved
    t.string  :cached_tag_list
  end unless ActiveRecord::Base.connection.table_exists?('has_filter_articles')

  create_table "has_filter_categories", :force => true do |t|
    t.string  :title
  end unless ActiveRecord::Base.connection.table_exists?('has_filter_categories')

  create_table "has_filter_categorizations", :force => true do |t|
    t.integer :category_id
    t.integer :has_filter_article_id
  end unless ActiveRecord::Base.connection.table_exists?('has_filter_categorizations')
  
  create_table :tags, :force => true do |t|
    t.column :name, :string
  end unless ActiveRecord::Base.connection.table_exists?('tags')

  create_table :taggings, :force => true do |t|
    t.column :tag_id, :integer
    t.column :taggable_id, :integer
    t.column :taggable_type, :string
    t.column :created_at, :datetime
  end unless ActiveRecord::Base.connection.table_exists?('taggings')
end
