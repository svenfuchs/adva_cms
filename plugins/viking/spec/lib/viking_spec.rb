require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe Viking do

 describe ".connect" do
    it "should load the Defensio engine" do
      Viking.connect('defensio', {}).should be_a_kind_of(Viking::Defensio)
    end
  
    it "should load the Akismet engine" do
      Viking.connect('akismet', {}).should be_a_kind_of(Viking::Akismet)
    end
  
    it "should be nil if the engine is nil" do
      Viking.connect(nil, {}).should be_nil
    end
  
    it "should be nil if the engine is blank" do
      Viking.connect('', {}).should be_nil
    end
  end
  
  describe ".enabled?" do
    it "should not be enabled if a default instance has not be initialized" do
      Viking.should_not be_enabled
    end
    
    it "should be enabled if a default instance has been initialized" do
      Viking.default_engine  = 'defensio'
      Viking.connect_options = '1234abc'
      
      Viking.should be_enabled
    end
  end

end