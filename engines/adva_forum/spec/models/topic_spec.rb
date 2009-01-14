require File.dirname(__FILE__) + '/../spec_helper'

describe Topic do
  include Stubby, Matchers::ClassExtensions

  before :each do
    stub_scenario :forum_with_topics

    @user = stub_user

    @topic = Topic.new :title => 'topic title', :body => 'body, just so it validates', :author => @user
    @topic.site = @site
    @topic.section = @section
  end
  
  it "delegates comment_filter to a site" do
    @site.stub!(:comment_filter).and_return 'filter'
    @topic.comment_filter.should == @site.comment_filter
  end

  describe "class extensions:" do
    it "has a permalink generated from the title" do
      Topic.should have_a_permalink(:title)
    end

    it 'acts as a commentable' do
      Topic.should act_as_commentable
    end

    it 'acts as a role context' do
      Topic.should act_as_role_context(:parent => Board)
    end

    # it 'specifies implicit roles (author roles for comments)' do
    #   @topic.should respond_to(:implicit_roles)
    # end

    it "has a comments counter" do
      Topic.should have_counter(:comments)
    end
  end

  describe 'associations:' do
    it 'belongs to a site' do
      @topic.should belong_to(:site)
    end

    it 'belongs to a section' do
      @topic.should belong_to(:section)
    end

    it 'belongs to a board' do
      @topic.should belong_to(:board)
    end

    it 'belongs to a last comment' do
      @topic.should belong_to(:last_comment)
    end

    it 'belongs to a author' do
      @topic.should belong_to(:author)
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
      @topic.stub!(:set_site) # otherwise conflicts with the implementation of validate_presence_of
      @topic.should validate_presence_of(:title)
    end
    
    it 'validates the presence of a body on create' do
      @topic.stub!(:set_site) # otherwise conflicts with the implementation of validate_presence_of
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
        Topic.should_receive(:new).with(@attributes.merge(:author => @user)).and_return @topic
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
        @comment = Comment.new :commentable => @topic
      end

      it 'builds a new comment with the given attributes' do
        @topic.comments.should_receive(:build).and_return @comment
        @topic.reply @user, @attributes
      end

      it 'sets the comment author' do
        @topic.comments.stub!(:build).and_return @comment
        @comment.should_receive(:author=).with @user
        @topic.reply @user, @attributes
      end

      it 'sets the board' do
        @topic.comments.stub!(:build).and_return @comment
        @comment.should_receive(:board=).with @topic.board
        @topic.reply @user, @attributes
      end

      it 'sets itself as the commentable' do
        @topic.comments.stub!(:build).and_return @comment
        @comment.should_receive(:commentable=).with @topic
        @topic.reply @user, @attributes
      end

      it 'returns a valid comment when a valid, new author and a body were given' do
        @topic.save!
        anonymous = User.anonymous :name => 'anonymous', :email => 'anonymous@email.org'
        comment = @topic.reply anonymous, @attributes
        lambda { comment.save }.should_not raise_error
      end
    end

    describe "#revise" do
      before :each do
        @comment = stub_comment
        @board = Board.new
        @topic.save
        @topic.stub!(:comments).and_return [@comment]
        @topic.stub!(:board).and_return @board
      end
      
      it "does not touch the comments if topics board is not changed" do
        @topic.should_not_receive(:comments)
        @topic.revise @user, nil
      end
      
      it "updates topics comments when board of topics is changed" do
        @comment.should_receive(:update_attribute).with(:board_id, 1)
        @topic.revise @user, {:board_id => 1}
      end
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
        @section.stub!(:comments_per_page).and_return 10
      end

      it 'returns true when the comments_count is greater than the comments_per_page attribute of the section' do
        @topic.stub!(:comments_count).and_return 15
        @topic.paged?.should be_true
      end

      it 'returns false when the comments_count is not greater than the comments_per_page attribute of the section' do
        @topic.stub!(:comments_count).and_return 5
        @topic.paged?.should be_false
      end
    end

    describe '#last_page returns the number of the last page' do
      before :each do
        @section.stub!(:comments_per_page).and_return 10
      end

      it 'which is 1 when comments_count is 0' do
        @topic.stub!(:comments_count).and_return 0
        @topic.last_page.should == 1
      end

      it 'which is 1 when comments_count is lesser than comments_per_page' do
        @topic.stub!(:comments_count).and_return 5
        @topic.last_page.should == 1
      end

      it 'which is 1 when comments_count equals comments_per_page' do
        @topic.stub!(:comments_count).and_return 10
        @topic.last_page.should == 1
      end

      it 'which is 2 when comments_count is greater than comments_per_page' do
        @topic.stub!(:comments_count).and_return 15
        @topic.last_page.should == 2
      end
    end

    describe '#previous' do
      before :each do
        stub_scenario :forum_with_two_topic_fixtures
      end

      it 'returns the previous topic if present' do
        @latest_topic.previous.should == @earlier_topic
      end

      it 'returns nil if no previous topic exists' do
        @earlier_topic.previous.should be_nil
      end
    end

    describe '#next' do
      before :each do
        stub_scenario :forum_with_two_topic_fixtures
      end

      it 'returns the next topic' do
        @earlier_topic.next.should == @latest_topic
      end

      it 'returns nil if no next topic exists' do
        @latest_topic.next.should == nil
      end
    end

    describe '#after_comment_update' do
      before :each do
        @comment = stub_comment
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

      # it 'updates the section by calling after_topic_update' do
      #   @topic.section.should_receive(:after_topic_update)
      #   @topic.after_comment_update(@comment)
      # end
    end

    it '#set_site sets the site from the section' do
      @topic.section.should_receive(:site_id).and_return 1
      @topic.should_receive(:site_id=).with 1
      @topic.send :set_site
    end
    
    it '#initial_post returns the first post of the topic' do
      @topic.initial_post.should == @topic.comments.first
    end
  end
end
