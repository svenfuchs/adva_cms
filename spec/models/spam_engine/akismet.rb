require File.dirname(__FILE__) + '/../../spec_helper'

describe 'SpamEngine:', 'the Akismet Filter' do
  before :each do
    @akismet = SpamEngine::Filter::Akismet.new :key => 'akismet key', :url => 'akismet url', :priority => 2    
    @comment = Comment.new
    @context = {:url => 'http://domain.org/an-article'}     
  end
  
  it "returns the key" do
    @akismet.key.should == 'akismet key'
  end
  
  it "returns the url" do
    @akismet.url.should == 'akismet url'
  end
  
  it "returns the priority" do
    @akismet.priority.should == 2
  end

  describe "when properly configured" do
    before :each do
      @akismet = SpamEngine::Filter::Akismet.new :key => 'akismet key', :url => 'akismet url', :priority => 2    
      Viking::Akismet.stub!(:new).and_return stub("viking", :check_comment => false)
    end
    
    describe "#check_comment" do
      it "instantiates a Viking Akismet backend" do
        Viking::Akismet.should_receive(:new).and_return stub("viking", :check_comment => false)
        @akismet.check_comment(@comment, @context)
      end
    
      it "returns a new SpamReport populated with the results from the backend" do
        report = @akismet.check_comment(@comment, @context)
        report.should be_instance_of(SpamReport)
        report.engine.should == 'Akismet'
        report.spaminess.should == 100
      end
    end    
  end
  
  describe 'when the key is missing' do
    before :each do
      @akismet = SpamEngine::Filter::Akismet.new :url => 'akismet url', :priority => 2    
    end
    
    it 'raises NotConfigured when calling #check_comment' do
      lambda { @akismet.check_comment(@comment, @context) }.should raise_error(SpamEngine::NotConfigured)
    end
    
    it 'raises NotConfigured when calling #mark_as_ham' do
      lambda { @akismet.mark_as_ham(@comment, @context) }.should raise_error(SpamEngine::NotConfigured)
    end
    
    it 'raises NotConfigured when calling #mark_as_spam' do
      lambda { @akismet.mark_as_spam(@comment, @context) }.should raise_error(SpamEngine::NotConfigured)
    end
    
    it 'the raised exception lists the error'
  end
  
  describe 'when the url is missing' do
    before :each do
      @akismet = SpamEngine::Filter::Akismet.new :key => 'akismet key', :priority => 2    
    end
    
    it 'raises NotConfigured when calling #check_comment' do
      lambda { @akismet.check_comment(@comment, @context) }.should raise_error(SpamEngine::NotConfigured)
    end
    
    it 'raises NotConfigured when calling #mark_as_ham' do
      lambda { @akismet.mark_as_ham(@comment, @context) }.should raise_error(SpamEngine::NotConfigured)
    end
    
    it 'raises NotConfigured when calling #mark_as_spam' do
      lambda { @akismet.mark_as_spam(@comment, @context) }.should raise_error(SpamEngine::NotConfigured)
    end
    
    it 'the raised exception lists the error'
  end
end