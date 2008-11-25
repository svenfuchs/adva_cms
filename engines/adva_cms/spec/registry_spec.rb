$:.unshift File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))
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

describe Registry, '#set' do
  before :all do
    Registry.backup!
  end

  before :each do
    @registry = Registry.instance
    @registry.clear
  end

  after :all do
    Registry.restore!
  end

  it "sets stuff" do
    @registry.set :foo, :bar
    @registry.should == {:foo => :bar}
  end

  it "sets stuff to nested keys" do
    @registry.set :foo, :bar, :baz, :buz
    @registry.should == {:foo => {:bar => {:baz => :buz}}}
  end

  it "recursively turns passed hashes into registries" do
    @registry.set :foo, {:bar => {:baz => :buz}}
    @registry.get(:foo).get(:bar).should be_instance_of(Registry)
  end
end

describe Registry, '#get' do
  before :all do
    Registry.backup!
  end

  before :each do
    @registry = Registry.instance
    @registry.set :foo, :bar, :baz, :buz
  end

  after :all do
    Registry.restore!
  end

  it "gets stuff from nested keys" do
    @registry.get(:foo, :bar).should == {:baz => :buz}
  end

  it "returns nil if an intermediary key is missing" do
    @registry.get(:foo, :missing).should be_nil
  end
end

describe Registry, '#clear' do
  before :all do
    Registry.backup!
  end

  before :each do
    @registry = Registry.instance
    @registry.set :foo, :bar, :baz, :buz
  end

  after :all do
    Registry.restore!
  end

  it "clears registry" do
    @registry.get(:foo, :bar).should == {:baz => :buz}
    Registry.clear
    @registry.get(:foo, :bar).should be_nil
    @registry.should be_empty
  end

  it "returns nil if an intermediary key is missing" do
    @registry.get(:foo, :missing).should be_nil
  end
end
