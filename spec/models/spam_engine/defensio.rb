require File.dirname(__FILE__) + '/../../spec_helper'

describe 'SpamEngine:', 'the Defensio Filter' do
  before :each do
    @defensio = SpamEngine::Filter::Defensio.new :key => 'defensio key', :url => 'defensio url', :priority => 2
    @comment = Comment.new
    @comment.stub!(:commentable).and_return stub('commentable', :published_at => Time.now)
    @context = {:url => 'http://domain.org/an-article'}
  end

  it "returns the key" do
    @defensio.key.should == 'defensio key'
  end

  it "returns the url" do
    @defensio.url.should == 'defensio url'
  end

  it "returns the priority" do
    @defensio.priority.should == 2
  end

  describe "when properly configured" do
    before :each do
      @defensio = SpamEngine::Filter::Defensio.new :key => 'defensio key', :url => 'defensio url', :priority => 2
      @result = {:spam => false, :spaminess => 33.0, :signature => 'signature'}
      Viking::Defensio.stub!(:new).and_return stub("viking", :check_comment => @result)
    end

    describe "#check_comment" do
      it "instantiates a Viking Defensio backend" do
        Viking::Defensio.should_receive(:new).and_return stub("viking", :check_comment => @result)
        @defensio.check_comment(@comment, @context)
      end

      it "returns a new SpamReport populated with the results from the backend" do
        report = @defensio.check_comment(@comment, @context)
        report.should be_instance_of(SpamReport)
        report.engine.should == 'Defensio'
        report.spaminess.should == 33.0
        report.data.should == {:spam => false, :spaminess => 33.0, :signature => 'signature'}
      end
    end
  end

  describe 'when the key is missing' do
    before :each do
      @defensio = SpamEngine::Filter::Defensio.new :url => 'defensio url', :priority => 2
    end

    it 'raises NotConfigured when calling #check_comment' do
      lambda { @defensio.check_comment(@comment, @context) }.should raise_error(SpamEngine::NotConfigured)
    end

    it 'raises NotConfigured when calling #mark_as_ham' do
      lambda { @defensio.mark_as_ham(@comment, @context) }.should raise_error(SpamEngine::NotConfigured)
    end

    it 'raises NotConfigured when calling #mark_as_spam' do
      lambda { @defensio.mark_as_spam(@comment, @context) }.should raise_error(SpamEngine::NotConfigured)
    end

    it 'the raised exception lists the error'
  end

  describe 'when the url is missing' do
    before :each do
      @defensio = SpamEngine::Filter::Defensio.new :key => 'defensio key', :priority => 2
    end

    it 'raises NotConfigured when calling #check_comment' do
      lambda { @defensio.check_comment(@comment, @context) }.should raise_error(SpamEngine::NotConfigured)
    end

    it 'raises NotConfigured when calling #mark_as_ham' do
      lambda { @defensio.mark_as_ham(@comment, @context) }.should raise_error(SpamEngine::NotConfigured)
    end

    it 'raises NotConfigured when calling #mark_as_spam' do
      lambda { @defensio.mark_as_spam(@comment, @context) }.should raise_error(SpamEngine::NotConfigured)
    end

    it 'the raised exception lists the error'
  end
end