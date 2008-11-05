require File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib', 'registry' ))

describe Registry, '#set' do
  before :each do
    @registry = Registry.instance
    @registry.clear
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
  before :each do
    @registry = Registry.instance
    @registry.set :foo, :bar, :baz, :buz
  end
  
  it "gets stuff from nested keys" do
    @registry.get(:foo, :bar).should == {:baz => :buz}
  end
  
  it "returns nil if an intermediary key is missing" do
    @registry.get(:foo, :missing).should be_nil
  end
end