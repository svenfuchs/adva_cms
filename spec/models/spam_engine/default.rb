require File.dirname(__FILE__) + '/../../spec_helper'

describe 'SpamEngine:', 'the Default Filter' do
  before :each do
    @filter = SpamEngine::Filter::Default.new :priority => 1, :always_ham => false, :authenticated_ham => false
    @comment = Comment.new
    @context = {:url => 'http://domain.org/an-article'}     
  end
  
  it "returns the priority" do
    @filter.priority.should == 1
  end
  
  describe "#check_comment" do
    it "returns a new SpamReport" do
      report = @filter.check_comment(@comment, @context)
      report.should be_instance_of(SpamReport)
      report.engine.should == 'Default'
    end
    
    it "reports a spaminess of 0.0 if :always_ham is true" do
      @filter.options[:always_ham] = true
      report = @filter.check_comment(@comment, @context)
      report.spaminess.should == 0.0
    end
    
    it "reports a spaminess of 0.0 if :authenticated_ham is true" do
      @filter.options[:authenticated_ham] = true
      report = @filter.check_comment(@comment, @context)
      report.spaminess.should == 0.0
    end
    
    it "reports a spaminess of 100.0 if neither :always_ham nor :authenticated_ham are true" do
      report = @filter.check_comment(@comment, @context)
      report.spaminess.should == 100.0
    end
  end
end