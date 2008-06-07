require File.dirname(__FILE__) + '/../spec_helper'

describe Comment do
  include Stubby
  
  before :each do 
    scenario :wiki, :wikipage, :user
    
    @comment = Comment.new :body => 'the body'
    @comment.author = @user    
    @comment.commentable = @wikipage
    @comment.commentable_type = 'Wiki'
    @comment.commentable_id = 1
  end  
  
  it "should belong to a commentable" do
    @comment.should belong_to(:commentable)
  end
  
  it "should validate presence of author_id" do
    @comment.should validate_presence_of(:author_id)
  end
  
  it "should validate presence of body" do
    @comment.should validate_presence_of(:body)
  end
  
  it "should validate presence of commentable" do
    @comment.should validate_presence_of(:commentable)
  end
  
  it "should return a link as author_link when author_url is present" do
    @comment.stub!(:author_homepage).and_return 'http://somewhere.com'
    @comment.author_link.should == '<a href="http://somewhere.com">name</a>'
  end
  
  it "should return author_name as author_link when author_url is not present" do
    @comment.stub!(:author_homepage).and_return nil
    @comment.author_link.should == 'name'
  end
  
  it "should call commentable.accept_comments? before creating a comment" do
    @wikipage.should_receive(:accept_comments?).and_return(false)
    lambda { @comment.save! }.should raise_error
  end
  
  it "should raise Comment::CommentNotAllowed when commentable.accept_comments? returns false before creating a comment" do
    @wikipage.stub!(:accept_comments?).and_return(false)
    lambda { @comment.save! }.should raise_error(Comment::CommentNotAllowed)
  end
end