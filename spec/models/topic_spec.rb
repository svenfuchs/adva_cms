require File.dirname(__FILE__) + '/../spec_helper'

describe Topic do
  include Stubby
  
  before :each do
    scenario :site, :section, :comment, :user

    @topic = Topic.new 
    @topic.section = @section
  end
  
  describe "class extensions:" do
    it "creates a permalink from the title"
    it 'acts as a commentable'
    it 'acts as a role context'
    it 'specifies implicit roles (author roles for comments)' # TODO spec this?
  end
  
  describe 'associations:' do
    it 'belongs to a site' do
      @topic.should belong_to(:site)
    end
    
    it 'belongs to a section' do
      @topic.should belong_to(:section)
    end
    
    it 'belongs to a last comment' do
      @topic.should belong_to(:last_comment)
    end
    
    it 'belongs to a last_author' do
      @topic.should belong_to(:last_author)
    end
    
  end
  
  describe "callbacks:" do
    it 'sets the site before validation' do
      Topic.before_validation.should include(:set_site)
    end
  end
  
  describe 'validations:' do
    it 'validates the presence of a section' do
      @topic.stub!(:set_site) # otherwise conflicts with the implementation of validate_presence_of
      @topic.should validate_presence_of(:section)
    end
    
    it 'validates the presence of a title' do
      @topic.should validate_presence_of(:title)
    end
    
    it 'validates the presence of a body on create' do
      @topic.should validate_presence_of(:body) # TODO :on => :create
    end
  end
  
  describe "class methods:" do
    describe "#post" do
      before :each do
        @attributes = {:title => 'title', :body => 'body'}
        Topic.stub!(:new).and_return @topic
        @topic.stub!(:reply)
      end
      
      it "initializes a new Topic with the given attributes" do
        Topic.should_receive(:new).with(@attributes).and_return @topic
        Topic.post @user, @attributes
      end
      
      it "sets the current author as the topic's last_author" do
        @topic.should_receive(:last_author=).with @user
        Topic.post @user, @attributes
      end
      
      it "replies to the new topic with an initial comment" do
        @topic.should_receive(:reply)
        Topic.post @user, @attributes
      end
    end
  end
  
  describe 'instance methods:' do  
    it '#owner returns the section' do
      @topic.owner.should == @section
    end
    
    describe '#reply' do
      before :each do
        @attributes = {:body => 'body'}
        @topic.comments.stub!(:build).and_return @comment
      end
      
      it 'builds a new comment with the given attributes' do
        @topic.comments.should_receive(:build).and_return @comment
        @topic.reply @user, @attributes
      end
      
      it 'sets the comment author' do
        @comment.should_receive(:author=).with @user
        @topic.reply @user, @attributes
      end
      
      it 'sets itself as the commentable' do
        @comment.should_receive(:commentable=).with @topic
        @topic.reply @user, @attributes
      end
    end
    
    describe '#revise' do
      it 'should be specified and implemented' # not sure if this actually makes sense in the end
    end
    
    describe '#accept_comments?' do
      it 'returns true when it is not locked' do
        @topic.stub!(:locked?).and_return false
        @topic.accept_comments?.should be_true
      end

      it 'returns false when it is locked' do
        @topic.stub!(:locked?).and_return true
        @topic.accept_comments?.should be_false
      end      
    end
    
    describe '#paged?' do
      before :each do
        @section.stub!(:articles_per_page).and_return 10
      end
      
      it 'returns true when the comments_count is greater than the articles_per_page attribute of the section' do
        @topic.stub!(:comments_count).and_return 15
        @topic.paged?.should be_true
      end
      
      it 'returns false when the comments_count is not greater than the articles_per_page attribute of the section' do
        @topic.stub!(:comments_count).and_return 5
        @topic.paged?.should be_false
      end
    end
    
    describe '#last_page returns the number of the last page' do
      before :each do
        @section.stub!(:articles_per_page).and_return 10
      end
      
      it 'which is 1 when comments_count is 0' do
        @topic.stub!(:comments_count).and_return 0
        @topic.last_page.should == 1
      end
      
      it 'which is 1 when comments_count is lesser than articles_per_page' do
        @topic.stub!(:comments_count).and_return 5
        @topic.last_page.should == 1
      end
      
      it 'which is 1 when comments_count equals articles_per_page' do
        @topic.stub!(:comments_count).and_return 10
        @topic.last_page.should == 1
      end
      
      it 'which is 2 when comments_count is greater than articles_per_page' do
        @topic.stub!(:comments_count).and_return 15
        @topic.last_page.should == 2
      end
    end
    
    it '#previous returns the previous topic'
    it '#next returns the next topic'
    
    describe '#after_comment_update' do
      before :each do
        scenario :comment
        @topic.section.stub!(:after_topic_update)
        @topic.stub!(:update_attributes!)
        @topic.stub!(:destroy)
      end
      
      it 'destroys itself if the comment was destroyed and no more comments exist' do
        @comment.stub!(:frozen?).and_return true
        @topic.comments.stub!(:last_one).and_return nil
        @topic.should_receive(:destroy)
        @topic.after_comment_update(@comment)
      end
      
      it 'updates its cache attributes if the comment was saved' do
        @topic.comments.stub!(:last_one).and_return nil
        @topic.should_receive(:update_attributes!)
        @topic.after_comment_update(@comment)
      end
      
      it 'updates its cache attributes if the comment was destroyed but more comments exist' do
        @comment.stub!(:frozen?).and_return true
        @topic.comments.stub!(:last_one).and_return @comment
        @topic.should_receive(:update_attributes!)
        @topic.after_comment_update(@comment)
      end
      
      it 'updates the section by calling after_topic_update' do
        @topic.section.should_receive(:after_topic_update)
        @topic.after_comment_update(@comment)
      end
    end
    
    it '#set_site sets the site from the section' do
      @topic.section.should_receive(:site_id).and_return 1
      @topic.should_receive(:site_id=).with 1
      @topic.send :set_site
    end
  end  
end