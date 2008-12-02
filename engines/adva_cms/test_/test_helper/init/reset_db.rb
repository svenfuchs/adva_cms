# this is super expensive, don't use it

# Test::Unit::TestCase.class_eval do
#   setup do
#     ActiveRecord::Base.connection.tables.each do |table_name|
#       next if table_name == 'schema_migrations'
#       ActiveRecord::Base.connection.execute "DELETE FROM #{table_name}"
#     end
#   end
# end
