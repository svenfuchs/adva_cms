require 'test/unit' 

$LOAD_PATH.unshift File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))
ENV['RAILS_ENV'] = 'test'

RAILS_ROOT = File.expand_path(File.dirname(__FILE__) + '/../../../../') unless defined? RAILS_ROOT

require 'rubygems'
require 'activerecord'
require 'active_record/fixtures'
require File.dirname(__FILE__) + '/../init.rb'

config = {'sqlite3' => {'adapter' => 'sqlite3', 'dbfile' => RAILS_ROOT + '/db/spec_better_nested_set.sqlite3.db'}}
ActiveRecord::Base.logger = Logger.new(RAILS_ROOT + '/log/spec_better_nested_set.log')
ActiveRecord::Base.establish_connection(config[ENV['DB'] || 'sqlite3'])

