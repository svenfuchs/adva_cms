require 'active_record/schema_dumper'

config = YAML::load(IO.read("#{RAILS_ROOT}/config/database.yml"))
ActiveRecord::Base.logger = Logger.new("#{RAILS_ROOT}/log/test.log")
ActiveRecord::Base.establish_connection(config['sqlite3'])

File.open("#{RAILS_ROOT}/db/schema.rb", "w") do |file|
  ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, file)
end

# load schema before each test run
ActiveRecord::Migration.verbose = false
ActionController::IntegrationTest.class_eval do
  setup do
    load("#{RAILS_ROOT}/db/schema.rb")
    # ActiveRecord::Base.connection.tables.each do |table_name|
    #   next if table_name == 'schema_migrations'
    #   ActiveRecord::Base.connection.execute "DELETE FROM #{table_name}"
    # end
  end
end

