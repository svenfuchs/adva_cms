require File.dirname(__FILE__) + '/../spec_helper'

describe Topic do
  include Stubby
  
  before :each do
    scenario :site, :section, :category, :user

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
      it "initializes a new Topic with the given attributes"
      it "sets the current author as the topic's last_author"
      it "replies to the new topic with an initial comment"
    end
  end
  
  describe 'instance methods:' do  
    it '#owner returns the section' do
      @topic.owner.should == @section
    end
    
    describe '#reply' do
      it 'builds a new comment with the given attributes'
      it 'sets the comment author'
      it 'sets itself as the commentable'
    end
    
    describe '#revise' do
      it 'should be specified and implemented' # not sure if this actually makes sense in the end
    end
    
    it '#accepts_comments? returns true when it is not locked'
    it '#paged? returns true when the comments_count is greater than the articles_per_page attribute of the section'
    it '#last_page returns the number of the last page'
    it '#previous returns the previous topic'
    it '#next returns the next topic'
    
    describe '#after_comment_update' do
      it 'destroys itself if the comment was destroyed and no more comments exist'
      it 'updates its cache attributes if the comment was saved'
      it 'updates its cache attributes if the comment was destroyed but more comments exist'
      it 'updates the section by calling after_topic_update'
    end
    
    it '#set_site sets the site from the section'
  end  
end