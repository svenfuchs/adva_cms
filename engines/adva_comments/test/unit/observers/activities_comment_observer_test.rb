require File.expand_path(File.dirname(__FILE__) + "/../../test_helper")

if Rails.plugin?(:adva_activity)
  class ActivitiesCommentObserverTest < ActiveSupport::TestCase
    def setup
      super
      Comment.old_add_observer(@observer = Activities::CommentObserver.instance)
      @approved = Article.first.approved_comments.first
      @unapproved = Article.first.unapproved_comments.first
    end
  
    def teardown
      super
      Comment.delete_observer(@observer)
    end
  
    test "logs a 'created' activity when the comment is a new_record" do
      comment = Comment.create! :body => 'body', 
                                :commentable => @approved.commentable, 
                                :author => @approved.author

      comment.activities.first.actions.should == ['created']
    end

    test "logs an 'edited' activity when the comment already exists" do
      @approved.update_attributes! :body => 'body was updated'
      @approved.activities.first.actions.should == ['edited']
    end
  
    test "logs an 'approved' activity when the comment is approved and :approved has changed" do
      @unapproved.update_attributes! :approved => 1
      @unapproved.activities.first.actions.should == ['approved']
    end
  
    test "logs a 'unapproved' activity when the comment is a draft and :approved has changed" do
      @approved.update_attributes! :approved => 0
      @approved.activities.first.actions.should == ['unapproved']
    end
  
    test "logs a 'deleted' activity when the comment is destroyed" do
      @approved.destroy
      @approved.activities.first.actions.should == ['deleted']
    end
  end
end