require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/../spec_helpers/spec_activity_helper'

describe Activities::CommentObserver do
  include SpecActivityHelper
  include Stubby
  
  it "should log a 'created' activity on save when the comment is a new_record" do
    scenario :comment_created
    expect_activity_new_with :actions => ['created']
    Comment.with_observers('activities/comment_observer') { @comment.save! }
  end
  
  it "should log an 'edited' activity on save when the comment already exists" do
    scenario :comment_updated
    expect_activity_new_with :actions => ['edited']
    Comment.with_observers('activities/comment_observer') { @comment.save! }
  end
  
  it "should log an 'approved' activity on save when the comment is approved and the approved attribute has changed" do
    scenario :comment_approved
    expect_activity_new_with :actions => ['approved']
    Comment.with_observers('activities/comment_observer') { @comment.save! }
  end
  
  it "should log a 'unapproved' activity on save when the comment is a draft and the approved attribute has changed" do
    scenario :comment_unapproved
    expect_activity_new_with :actions => ['unapproved']
    Comment.with_observers('activities/comment_observer') { @comment.save! }
  end
  
  it "should log a 'deleted' activity on destroy" do
    scenario :comment_destroyed
    expect_activity_new_with :actions => ['deleted']
    Comment.with_observers('activities/comment_observer') { @comment.destroy }
  end
end