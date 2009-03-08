require 'test/unit'

require 'rubygems'
require 'activesupport'
require 'active_support/test_case'
require 'activerecord'
require 'active_record/fixtures'

dir = File.dirname(__FILE__)
$: << File.expand_path(File.join(dir, '..', 'lib'))
ENV['RAILS_ENV'] = 'test'

require dir + '/../init.rb'

config = { 'test' => { 'adapter' => 'sqlite3', 'dbfile' => dir + '/db/simple_nested_set.sqlite3.db' } }

ActiveRecord::Base.logger = Logger.new(dir + '/log/simple_nested_set.log')
ActiveRecord::Base.configurations = config
ActiveRecord::Base.establish_connection(config['test'])

class ActiveSupport::TestCase #:nodoc:
  include ActiveRecord::TestFixtures

  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = true
  self.fixture_path = File.dirname(__FILE__) + '/fixtures/'
end

require dir + '/fixtures/models.rb'
require dir + '/db/schema.rb' unless Node.table_exists?
