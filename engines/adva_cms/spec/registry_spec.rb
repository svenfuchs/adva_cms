require File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib', 'registry' ))

describe Registry, '#set' do
  before :each do
    Registry.clear
  end
  
  it "sets it" do
    Registry.set :foo, :bar
    Registry.should == {:foo => :bar}
  end
end