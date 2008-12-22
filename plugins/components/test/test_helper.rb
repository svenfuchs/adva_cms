# fake the rails root
RAILS_ROOT = File.dirname(__FILE__)

# require support libraries
require 'test/unit'
require 'rubygems'
gem 'rails', '2.2.2'
require 'active_support'
require 'action_controller'
require 'action_controller/test_process' # for the assertions
require 'action_view'
require 'active_record'
require 'logger'
require 'mocha'

RAILS_DEFAULT_LOGGER = Logger.new(File.dirname(__FILE__) + '/debug.log')

%w(../lib app/controllers).each do |load_path|
  ActiveSupport::Dependencies.load_paths << File.dirname(__FILE__) + "/" + load_path
end

require File.dirname(__FILE__) + '/../init'

ActionController::Base.cache_store = :memory_store
