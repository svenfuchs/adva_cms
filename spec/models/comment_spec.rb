require File.dirname(__FILE__) + '/../spec_helper'

describe Comment do
  include Stubby
  include Matchers::FilterColumn
  
  before :each do 
    scenario :site, :wiki, :wikipage, :user
    
    @comment = Comment.new :body => 'the body'
    @comment.site = @site
    @comment.section = @wiki
    @comment.author = @user    
    @comment.commentable = @wikipage
    @comment.commentable_type = 'Wiki'
    @comment.commentable_id = 1
    
  end
  
  describe 'class extensions:' do
    it 'acts as a role context for the author role'
    it 'sanitizes the body_html attribute'
    
    it "filters the body column" do
      @comment.should filter_column(:body)
    end
  end
  
  describe 'associations:' do  
    it "belongs to a site" do
      @comment.should belong_to(:site)
    end
    
    it "belongs to a section" do
      @comment.should belong_to(:section)
    end
    
    it "belongs to a commentable" do
      @comment.should belong_to(:commentable)
    end
  end
  
  describe 'validations:' do  
    it "validates presence of author (through belongs_to_author)" do
      @comment.should validate_presence_of(:author)
    end
  
    it "validates presence of body" do
      @comment.should validate_presence_of(:body)
    end
  
    it "validates presence of commentable" do
      @comment.should validate_presence_of(:commentable)
    end
  end
  
  describe 'callbacks:' do
    it 'sets owners (site + section) before validation' do
      Comment.before_validation.should include(:set_owners)
    end

    it 'authorizes commenting before create' do
      Comment.before_create.should include(:authorize_commenting!)
    end

    it 'updates the commentable after create' do
      Comment.after_create.should include(:update_commentable)
    end

    it 'updates the commentable after destroy' do
      Comment.after_destroy.should include(:update_commentable)
    end
  end
  
  describe 'instance methods:' do
    it '#owner returns the commentable' do
      @comment.stub!(:commentable).and_return(@wikipage)
      @comment.owner.should == @wikipage
    end
    
    it '#filter returns the comment_filter attribute of the commentable' do
      @comment.commentable.should_receive(:comment_filter)
      @comment.filter
    end
    
    describe '#approved?' do    
      it 'returns true if the approved attribute is not 0' do
        @comment.approved = 1
        @comment.approved?.should be_true
      end
    
      it 'returns true if the approved attribute is 0' do
        @comment.approved = 0
        @comment.approved?.should be_false
      end
    end
    
    describe '#authorize_commenting!' do
      it 'it checks if the commentable accepts comments' do
        @comment.commentable.should_receive(:accept_comments?).and_return true
        @comment.authorize_commenting!
      end
      
      it 'it raises CommentNotAllowed if the commentable does not accept comments' do
        @comment.commentable.stub!(:accept_comments?).and_return false
        lambda{ @comment.authorize_commenting! }.should raise_error
      end
    end
    
    describe '#set_owners' do
      it 'sets site from the commentable' do
        @comment.commentable.should_receive(:site)
        @comment.should_receive(:site=)
        @comment.send :set_owners
      end

      it 'sets section from the commentable' do
        @comment.commentable.should_receive(:section)
        @comment.should_receive(:section=)
        @comment.send :set_owners
      end
    end
    
    it '#update_commentable calls #after_comment_update on the commentable' do
      @comment.commentable.should_receive(:after_comment_update)
      @comment.send :update_commentable
    end
  end
  
  it "returns a link as author_link when author_url is present" do
    @comment.stub!(:author_homepage).and_return 'http://somewhere.com'
    @comment.author_link.should == '<a href="http://somewhere.com">name</a>'
  end
  
  it "returns author_name as author_link when author_url is not present" do
    @comment.stub!(:author_homepage).and_return nil
    @comment.author_link.should == 'name'
  end
  
  it "calls commentable.accept_comments? before creating a comment" do
    @wikipage.should_receive(:accept_comments?).and_return(false)
    lambda { @comment.save! }.should raise_error
  end
  
  it "raises Comment::CommentNotAllowed when commentable.accept_comments? returns false before creating a comment" do
    @wikipage.stub!(:accept_comments?).and_return(false)
    lambda { @comment.save! }.should raise_error(Comment::CommentNotAllowed)
  end
end