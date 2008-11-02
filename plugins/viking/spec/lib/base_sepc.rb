require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

module BaseSpecHelper
  def valid_base_options
    {
      :api_key => "1234abc", 
      :blog    => "wiki.mysite.com"
    }
  end
end

describe Viking::Base do

  attr_accessor :base
  
  before(:each) do
    self.base = Viking::Base.new({})
  end
  
  after(:each) do
    self.base = nil
  end

  describe "#mark_as_spam_or_ham" do
    it "should mark as spam when is_spam is true" do
      base.should_receive(:mark_as_spam).and_return("I will be spam")
      base.mark_as_spam_or_ham(true, {}).should == "I will be spam"
    end
    
    it "should mark as ham when is_spam is false" do
      base.should_receive(:mark_as_ham).and_return("I will be ham")
      base.mark_as_spam_or_ham(false, {}).should == "I will be ham"
    end
  end
  
  describe "#invalid_options?" do
    include BaseSpecHelper
    
    it "should be false if the required options are non-nil" do
      base.options = valid_base_options
      base.should_not be_invalid_options
    end
    
    it "should be true if the options don't include an API key" do
      base.options = valid_base_options.except(:api_key)
      base.should be_invalid_options
    end
    
    it "should be true if the options don't include a blog address" do
      base.options = valid_base_options.except(:blog)
      base.should be_invalid_options
    end
  end

end