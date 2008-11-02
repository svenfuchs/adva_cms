# NOTE: Inherited from acts_as_versioned

$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'test/unit'
require File.expand_path(File.join(File.dirname(__FILE__),
  '..', '..', '..', '..', 'config', 'environment.rb'))
require 'active_record/fixtures'

config = YAML::load(IO.read(File.join(File.dirname(__FILE__), 'database.yml')))
ActiveRecord::Base.logger =
  Logger.new(File.join(File.dirname(__FILE__), 'debug.log'))
ActiveRecord::Base.establish_connection(config[ENV['DB'] || 'sqlite3'])

load(File.join(File.dirname(__FILE__), 'schema.rb'))

Test::Unit::TestCase.fixture_path = File.join(File.dirname(__FILE__),'fixtures')
$LOAD_PATH.unshift(Test::Unit::TestCase.fixture_path)

class Test::Unit::TestCase #:nodoc:
  def create_fixtures(*table_names)
    if block_given?
      Fixtures.create_fixtures(Test::Unit::TestCase.fixture_path, table_names) { yield }
    else
      Fixtures.create_fixtures(Test::Unit::TestCase.fixture_path, table_names)
    end
  end

  require File.join(File.dirname(__FILE__), 'test_helper.rb')
end
