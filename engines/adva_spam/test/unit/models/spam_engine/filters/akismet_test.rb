require File.dirname(__FILE__) + '/../../../../test_helper'

module SpamTests
  class SpamEngineFilterAkismetTest < ActiveSupport::TestCase
    def setup
      super
      @filter = SpamEngine::Filter::Akismet.new :key => 'akismet key', :url => 'akismet url', :priority => 2
      @comment = Comment.first
      @context = {:url => 'http://domain.org/an-article', :authenticated => true}
    
      @viking = Viking::Akismet.new({})
      stub(@viking).check_comment.returns({ :spam => false, :message => "" })
      stub(@filter).backend.returns(@viking)
    end

    test "returns the key" do
      @filter.key.should == 'akismet key'
    end

    test "returns the url" do
      @filter.url.should == 'akismet url'
    end

    test "returns the priority" do
      @filter.priority.should == 1
    end

    # when properly configured
    test "instantiates a Viking Akismet backend" do
      mock(@filter).backend.returns(@viking)
      @filter.check_comment(@comment, @context)
    end

    test "returns a new SpamReport populated with the results from the backend" do
      @filter.check_comment(@comment, @context)
      report = @comment.spam_reports.first
      report.should be_instance_of(SpamReport)
      report.engine.should == 'Akismet'
      report.spaminess.should == 0
    end
  
    # FIXME currently not happening ... i wonder how to design this stuff anyway.
    #
    # # when key not configured
    # test 'raises NotConfigured when calling #check_comment' do
    #   @filter.options[:key] = nil
    #   lambda { @filter.check_comment(@comment, @context) }.should raise_error(SpamEngine::NotConfigured)
    # end
    # 
    # test 'raises NotConfigured when calling #mark_as_ham' do
    #   @filter.options[:key] = nil
    #   lambda { @filter.mark_as_ham(@comment, @context) }.should raise_error(SpamEngine::NotConfigured)
    # end
    # 
    # test 'raises NotConfigured when calling #mark_as_spam' do
    #   @filter.options[:key] = nil
    #   lambda { @filter.mark_as_spam(@comment, @context) }.should raise_error(SpamEngine::NotConfigured)
    # end
    # 
    # # when url not configured
    # it 'raises NotConfigured when calling #check_comment' do
    #   @filter.options[:url] = nil
    #   lambda { @filter.check_comment(@comment, @context) }.should raise_error(SpamEngine::NotConfigured)
    # end
    # 
    # it 'raises NotConfigured when calling #mark_as_ham' do
    #   @filter.options[:url] = nil
    #   lambda { @filter.mark_as_ham(@comment, @context) }.should raise_error(SpamEngine::NotConfigured)
    # end
    # 
    # it 'raises NotConfigured when calling #mark_as_spam' do
    #   @filter.options[:url] = nil
    #   lambda { @filter.mark_as_spam(@comment, @context) }.should raise_error(SpamEngine::NotConfigured)
    # end
  end
end