require 'stubby/class_factory'
require 'stubby/definition'
require 'stubby/handle'
require 'stubby/has_many_proxy'
require 'stubby/instances'
require 'stubby/scenario'
require 'stubby/stub'

module Stubby
  module Classes; end
    
  class << self
    def load
      Definition::Loader.load
      Scenario::Loader.load
    end
  end
end

# trying to guess the stub definitions directory, overwrite this setting 
# as needed in your spec_helper.rb
if filename = caller.detect{|line| line !~ /rubygems|dependencies/ }
  Stubby::Definition.directory = File.expand_path File.dirname(filename) + "/stubs"
  Stubby::Scenario.directory = File.expand_path File.dirname(filename) + "/scenarios"
end
