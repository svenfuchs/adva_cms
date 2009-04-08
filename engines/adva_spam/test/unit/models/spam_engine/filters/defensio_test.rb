require File.dirname(__FILE__) + '/../../../../test_helper'

module SpamTests
  class SpamEngineFilterDefensioTest < ActiveSupport::TestCase
    def setup
      super
      @filter = SpamEngine::Filter::Defensio.new :key => 'defensio key', :url => 'defensio url', :priority => 2
      @comment = Article.find_by_title('a blog article').unapproved_comments.first
      @context = {:url => 'http://domain.org/an-article', :authenticated => true}
    
      @viking = Viking::Defensio.new({})
      stub(@viking).check_comment.returns({:spam => false, :spaminess => 33.0, :signature => 'signature'})
      stub(@filter).backend.returns(@viking)
    end

    test "returns the key" do
      @filter.key.should == 'defensio key'
    end

    test "returns the url" do
      @filter.url.should == 'defensio url'
    end

    test "returns the priority" do
      @filter.priority.should == 1
    end

    # when properly configured
    test "instantiates a Viking Defensio backend" do
      mock(@filter).backend.returns(@viking)
      @filter.check_comment(@comment, @context)
    end

    test "returns a new SpamReport populated with the results from the backend" do
      @filter.check_comment(@comment, @context)
      report = @comment.spam_reports.first
      report.should be_instance_of(SpamReport)
      report.engine.should == 'Defensio'
      # report.spaminess.should == 33.0 # FIXME we currently do not use the :spaminess but the :spam result
      report.spaminess.should == 0.0
      report.data.should == {:spam => false, :spaminess => 33.0, :signature => 'signature'}
    end
  end
end