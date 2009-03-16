begin
  ActiveRecord::Base.connection 
rescue ActiveRecord::ConnectionNotEstablished => e

  dir_name = File.dirname(__FILE__)
  log_file = "#{dir_name}/../log/test.log"
  db_file  = "#{dir_name}/test.sqlite3.db"

  FileUtils.mkdir_p(File.dirname(log_file)) unless File.exists?(File.dirname(log_file))

  ActiveRecord::Base.logger = Logger.new log_file
  ActiveRecord::Base.establish_connection :adapter => 'sqlite3', :dbfile => db_file

  unless ActiveRecord::Base.connection.table_exists?('has_filter_people')
    ActiveRecord::Migration.verbose = false
    ActiveRecord::Schema.define(:version => 20090126133510) do
      create_table "has_filter_articles", :force => true do |t|
        t.string  :title
        t.string  :body
        t.string  :tag_list
        t.integer :published
        t.integer :approved
      end

      create_table "has_filter_people", :force => true do |t|
        t.string :first_name
        t.string :last_name
        t.string :private_attribute
      end
    end
  end 
end
