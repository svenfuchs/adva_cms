require File.dirname(__FILE__) + '/../../../test_helper'

module SpamTests
  class SpamEngineFilterChainTest < ActiveSupport::TestCase
    def setup
      super

      options = {
        :filters => ['akismet', 'defensio'], # 'default' will be added by default
        :default => {:ham => 'none', :priority => 1},
        :akismet => {:key => 'akismet key', :url => 'akismet url', :priority => 2},
        :defensio => {:key => 'defensio key', :url => 'defensio url', :priority => 3}
      }
      @chain = SpamEngine::FilterChain.assemble options
      @default, @akismet, @defensio = *@chain

      @comment = Comment.new
      @context = {:url => 'http://domain.org/an-article'}
    end

    test "when called #assemble returns a filter chain with filters assembled" do
      @default.should be_instance_of(SpamEngine::Filter::Default)
      @default.options.should == {:ham => 'none', :priority => 1}

      @akismet.should be_instance_of(SpamEngine::Filter::Akismet)
      @akismet.options.should == {:key => 'akismet key', :url => 'akismet url', :priority => 2}

      @defensio.should be_instance_of(SpamEngine::Filter::Defensio)
      @defensio.options.should == {:key => 'defensio key', :url => 'defensio url', :priority => 3}
    end
  
    # FIXME how to do this with RR?
    #
    # test "when called #check_comment calls #check_comment on the filters in the correct order" do
    #   @default.should_receive(:check_comment) do
    #     @akismet.should_receive(:check_comment) do
    #       @defensio.should_receive(:check_comment).and_return true
    #     end
    #   end
    # 
    #   @comment.stub!(:add_spam_report)
    #   @chain.check_comment(@comment, @context)
    # end

    test "stops execution of further filters when a filter returned false" do
      mock(@default).check_comment(@comment, @context).returns false
      dont_allow(@akismet).check_comment(@comment, @context)
      dont_allow(@defensio).check_comment(@comment, @context)

      stub(@comment).add_spam_report(anything)
      @chain.check_comment(@comment, @context)
    end
  end
end