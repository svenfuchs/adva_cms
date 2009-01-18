require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

$:.unshift File.expand_path(File.dirname(__FILE__) + '/../../lib')
require 'registry'

class Registry
  @@old_instance = nil
    
  class << self
    def backup!
      @@old_instance = defined?(@@instance) ? @@instance.dup : Registry.new
    end

    def restore!
      @@instance = @@old_instance
    end
  end
end

class RegistryTest < ActiveSupport::TestCase
  def setup
    super
    Registry.backup!
    @registry = Registry.instance
  end

  def teardown
    super
    Registry.restore!
  end
  
  # set

  test "#set sets stuff" do
    @registry.clear
    @registry.set :foo, :bar
    @registry.should == {:foo => :bar}
  end

  test "#set sets stuff to nested keys" do
    @registry.clear
    @registry.set :foo, :bar, :baz, :buz
    @registry.should == {:foo => {:bar => {:baz => :buz}}}
  end

  test "#set recursively turns passed hashes into registries" do
    @registry.clear
    @registry.set :foo, {:bar => {:baz => :buz}}
    Registry.should === @registry.get(:foo).get(:bar) # FIXME write instance_of matcher
  end
  
  # get

  test "#get gets stuff from nested keys" do
    @registry.set :foo, :bar, :baz, :buz
    @registry.get(:foo, :bar).should == {:baz => :buz}
  end

  test "#get returns nil if an intermediary key is missing" do
    @registry.set :foo, :bar, :baz, :buz
    @registry.get(:foo, :missing).should == nil
  end
  
  # clear

  test "#clear clears registry" do
    @registry.set :foo, :bar, :baz, :buz
    @registry.get(:foo, :bar).should == {:baz => :buz}
    Registry.clear
    @registry.get(:foo, :bar).should == nil
    # FIXME write matcher
    # @registry.should be_empty
    assert @registry.empty?
  end

  test "#clear returns nil if an intermediary key is missing" do
    @registry.set :foo, :bar, :baz, :buz
    @registry.get(:foo, :missing).should == nil
  end
end
