require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

module SpamTests
  class CommentSpamTest < ActiveSupport::TestCase
    def setup
      super
      @section = Section.first
      @article = @section.articles.first
      @comment = @article.comments.first

      @engine = @section.spam_engine
      @report = SpamReport.new :engine => 'name', :spaminess => 0,
                               :data => {:spam => false, :spaminess => 0, :signature => 'signature'}
      @context = {:url => 'http://www.domain.org/an-article'}

      stub(@engine).check_comment(@comment, @context).returns(@report)
    end

    test "#check_approval gets a spam_engine from the section" do
      mock(@comment.section.target).spam_engine.returns @engine
      @comment.check_approval @context
    end

    test "#check_approval gets a spam report from calling #check_comment on the spam engine" do
      mock(@comment.section.spam_engine).check_comment(@comment, @context).returns @report
      @comment.check_approval @context
    end

    test "#check_approval calculates the comment's spaminess from its spam_reports" do
      mock(@comment).calculate_spaminess.returns 999
      @comment.check_approval @context
      @comment.spaminess.should == 999
    end

    test "#check_approval sets the comment approved if it is ham" do
      mock(@comment).ham?.returns true
      @comment.check_approval @context
      @comment.approved?.should be_true
    end

    test "#check_approval saves the comment" do
      mock(@comment).save!
      @comment.check_approval @context
    end
  end
end