require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/../spec_helpers/spec_activity_helper'

describe Activities::CommentObserver do
  include SpecActivityHelper
  include Stubby

  before :each do
    scenario :site, :section, :article, :user
    
    @article.class.stub!(:decrement_counter)
    @article.class.stub!(:increment_counter)
    
    @comment = Comment.new :body => 'body', 
                           :commentable_type => 'Article', 
                           :commentable_id => 1,
                           :commentable => @article, 
                           :author => @user
                           
    @comment.stub!(:body_changed?).and_return false
    @comment.stub!(:authorize_commenting?).and_return nil
  end
  
  it "should log a 'created' activity on save when the comment is a new_record" do
    expect_activity_new_with :actions => ['created']
    Comment.with_observers('activities/comment_observer') { @comment.save! }
  end
  
  it "should log an 'edited' activity on save when the comment already exists" do
    expect_activity_new_with :actions => ['edited']
    Comment.with_observers('activities/comment_observer') { edited(@comment).save! }
  end
  
  it "should log an 'approved' activity on save when the comment is approved and the approved attribute has changed" do
    expect_activity_new_with :actions => ['approved']
    Comment.with_observers('activities/comment_observer') { approved(@comment).save! }
  end
  
  it "should log a 'unapproved' activity on save when the comment is a draft and the approved attribute has changed" do
    expect_activity_new_with :actions => ['unapproved']
    Comment.with_observers('activities/comment_observer') { unapproved(@comment).save! }
  end
  
  it "should log a 'deleted' activity on destroy" do
    expect_activity_new_with :actions => ['deleted']
    Comment.with_observers('activities/comment_observer') { destroyed(@comment).destroy }
  end
end