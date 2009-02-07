begin
  ActiveRecord::Base.connection 
rescue ActiveRecord::ConnectionNotEstablished => e

  dir_name = File.dirname(__FILE__)
  log_file = "#{dir_name}/../log/test.log"
  db_file  = "#{dir_name}/test.sqlite3.db"

  FileUtils.mkdir_p(File.dirname(log_file)) unless File.exists?(File.dirname(log_file))

  ActiveRecord::Base.logger = Logger.new log_file
  ActiveRecord::Base.establish_connection :adapter => 'sqlite3', :dbfile => db_file

  unless ActiveRecord::Base.connection.table_exists?('people')
    ActiveRecord::Migration.verbose = false
    ActiveRecord::Schema.define(:version => 20090126133510) do
      create_table "people", :force => true do |t|
        t.string :first_name
        t.string :last_name
        t.string :private_attribute
      end
    end

  end 
end
