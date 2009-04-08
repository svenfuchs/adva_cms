require File.dirname(__FILE__) + '/../../../../test_helper'

module SpamTests
  class SpamEngineFilterDefaultTest < ActiveSupport::TestCase
    def setup
      super
      @filter = SpamEngine::Filter::Default.new :priority => 1, :always_ham => false, :authenticated_ham => false
      @comment = Comment.new
      @context = {:url => 'http://domain.org/an-article', :authenticated => true}
    end

    test "returns the priority" do
      @filter.priority.should == 0
    end

    "#check_comment"
    test "adds a new SpamReport to comment.spam_reports" do
      @filter.check_comment(@comment, @context)
      report = @comment.spam_reports.first
      report.should be_instance_of(SpamReport)
      report.engine.should == 'Default'
    end
  
    test "reports a spaminess of 0.0 if option :ham == 'all'" do
      @filter.options[:ham] = 'all'
      @filter.check_comment(@comment, @context)
      @comment.spam_reports.first.spaminess.should == 0.0
    end
  
    test "reports a spaminess of 0.0 if option :ham == 'authenticated' and the given context is :authenticated" do
      @filter.options[:ham] = 'authenticated'
      @filter.check_comment(@comment, @context)
      @comment.spam_reports.first.spaminess.should == 0.0
    end
  
    test "reports a spaminess of 100.0 if option :ham is neither 'all' nor 'authenticated'" do
      @filter.check_comment(@comment, @context)
      @comment.spam_reports.first.spaminess.should == 100.0
    end
  end
end