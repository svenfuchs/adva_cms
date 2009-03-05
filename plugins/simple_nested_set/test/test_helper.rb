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

class Node < ActiveRecord::Base
  unless table_exists?
    ActiveRecord::Migration.verbose = false
    ActiveRecord::Schema.define(:version => 1) do
      create_table "nodes", :force => true do |t|
        t.string  :name
        t.string  :type
        t.integer :lft
        t.integer :rgt
        t.integer :foo_id
        t.integer :parent_id
      end
    end
  end
end

class FooNode < Node
  acts_as_nested_set :scope => :foo_id
end