require 'stubby/handle'
require 'stubby/instances'
require 'stubby/loader'

require 'stubby/base'
require 'stubby/definition'
require 'stubby/class_factory'
require 'stubby/has_many_proxy'

module Stubby
  module Classes; end

  mattr_accessor :directory  
  mattr_accessor :scenarios, :base_definitions, :instance_definitions
  @@scenarios = {}  
  @@base_definitions = {}
  @@instance_definitions = {}
  
  class << self
    def included(base)
      base.after :each do Stubby::Instances.clear! end    
    end

    def base_definition(name)
      @@base_definitions[name]
    end

    def instance_definitions(name)
      @@instance_definitions[name] ||= {}
    end   
  end
  
  def scenario(*names)
    names.each do |name|
      raise "scenario :#{name} is not defined" unless scenarios[name]
      instance_eval &scenarios[name]
    end
  end
    
  def lookup(key, *args)
    Stubby::Instances.lookup(key.to_s, *args)
  end
  
  def method_missing(name, *args)
    return lookup($1, *args) if name.to_s =~ /^stub_(.*)/
    super
  end
end

# trying to guess the stub definitions directory, overwrite this setting 
# as needed in your spec_helper.rb
if filename = caller.detect{|line| line !~ /rubygems|dependencies/ }
  Stubby.directory = File.expand_path File.dirname(filename) + "/stubs"
end
