require File.expand_path(File.dirname(__FILE__) + '/../../test_helper.rb')

class TopicTest < ActiveSupport::TestCase
  def setup
    super
    @topic  = Topic.first
    @site   = @topic.section.site
    @user   = User.first
    @attributes = {:body => 'body'}
    @forum = Forum.find_by_permalink('a-forum-with-two-topics')
    @first_topic  = @forum.topics.find_by_permalink('first-topic')
    @last_topic   = @forum.topics.find_by_permalink('last-topic')
    stub(@last_topic).last_updated_at.returns 1.second.ago
    stub(@first_topic).last_updated_at.returns 3.months.ago
  end
  
  test "delegates comment_filter to a site" do
    @topic.comment_filter.should == @site.comment_filter
  end
  
  # Class extensions
  
  test "has a permalink generated from the title" do
    Topic.should have_permalink(:title)
  end

  test 'acts as a commentable' do
    Topic.should act_as_commentable
  end

  test 'acts as a role context' do
    Topic.should act_as_role_context(:parent => Board)
  end

  # test 'specifies implicit roles (author roles for comments)' do
  #   @topic.should respond_to(:implicit_roles)
  # end

  test "has a comments counter" do
    Topic.should have_counter(:comments)
  end
  
  # Associations
  
  test 'belongs to a site' do
    @topic.should belong_to(:site)
  end

  test 'belongs to a section' do
    @topic.should belong_to(:section)
  end

  test 'belongs to a board' do
    @topic.should belong_to(:board)
  end

  test 'belongs to a last comment' do
    @topic.should belong_to(:last_comment)
  end

  test 'belongs to a author' do
    @topic.should belong_to(:author)
  end

  test 'belongs to a last_author' do
    @topic.should belong_to(:last_author)
  end
  
  # Callbacks
  
  test 'sets the site before validation' do
    Topic.before_validation.should include(:set_site)
  end
  
  # Validations
  
  test 'validates the presence of a section' do
    stub(@topic).set_site # otherwise conflicts with the implementation of validate_presence_of
    @topic.should validate_presence_of(:section)
  end

  test 'validates the presence of a title' do
    stub(@topic).set_site # otherwise conflicts with the implementation of validate_presence_of
    @topic.should validate_presence_of(:title)
  end
  
  test 'validates the presence of a body on create' do
    @topic = Topic.new  # validates on create, needs a new Topic object for it
    stub(@topic).set_site # otherwise conflicts with the implementation of validate_presence_of
    @topic.should validate_presence_of(:body)
  end
  
  # Class methods
  
  # .post
  
  test "#post, initializes a new Topic with the given attributes" do
    topic = Topic.post(@user, {:title => 'new topic object'})
    topic.title.should == 'new topic object'
    topic.author.should == @user
  end

  test "#post, sets the current author as the topic's last_author" do
    topic = Topic.post(@user, @topic.attributes)
    topic.last_author.should == @user
  end

  test "#post, replies to the new topic with an initial post" do
    topic = Topic.post(@user, @topic.attributes)
    topic.initial_post.should_not be_nil
  end
  
  # Public methods
  
  # .owner
  
  test '#owner returns a section, when topic is on boardless forum' do
    forum = Forum.find_by_permalink('a-forum-without-boards')
    forum.topics.first.owner.should == forum
  end
  
  test '#owner returns a board, when topic is on board forum' do
    forum = Forum.find_by_permalink('a-forum-with-boards')
    topic = forum.topics.first
    topic.owner.should == topic.board
  end
  
  # .reply
  
  test '#reply, builds a new comment with the given attributes' do
    post = @topic.reply(@user, @attributes)
    post.should be_kind_of(Comment)
  end

  test '#reply, sets the comment author' do
    post = @topic.reply(@user, @attributes)
    post.author.should == @user
  end

  test '#reply, sets the board' do
    post = @topic.reply(@user, @attributes)
    post.board.should == @topic.board
  end

  test '#reply, sets itself as the commentable' do
    post = @topic.reply(@user, @attributes)
    post.commentable.should == @topic
  end

  test '#reply, returns a valid comment when a valid, new author and a body were given' do
    post = @topic.reply(@user, @attributes)
    lambda { post.save! }.should_not raise_error
  end
  
  # .revise
  
  test "#revise, does not touch the comments if topics board is not changed" do
    @topic.revise(@user, nil)
    @topic.comments.each do |comment|
      comment.board_id.should == @topic.board_id  
    end
  end
  
  test "#revise, updates topics comments when board of topics is changed" do
    @topic.revise(@user, {:board_id => 1})
    @topic.comments.each do |comment|
      comment.board_id.should == 1
    end
  end

  # .accept_comments?

  test '#accept_comments?, returns true when it is not locked' do
    @topic.accept_comments?.should be_true
  end

  test '#accept_comments?, returns false when it is locked' do
    @topic.update_attribute(:locked, 1)
    @topic.accept_comments?.should be_false
  end
  
  # .paged?
  
  test '#paged?, returns true when the comments_count is greater than the comments_per_page attribute of the section' do
    stub(@topic).comments_count.returns 150
    @topic.paged?.should be_true
  end

  test '#paged?, returns false when the comments_count is not greater than the comments_per_page attribute of the section' do
    stub(@topic).comments_count.returns 5
    @topic.paged?.should be_false
  end
  
  # .last_page
  
  test '#last_page, which is 1 when comments_count is 0' do
    stub(@topic).comments_count.returns 0
    @topic.last_page.should == 1
  end

  test '#last_page, which is 1 when comments_count is lesser than comments_per_page' do
    stub(@topic).comments_count.returns 5
    @topic.last_page.should == 1
  end

  test '#last_page, which is 1 when comments_count equals comments_per_page' do
    stub(@topic).comments_count.returns 10
    @topic.last_page.should == 1
  end

  test '#last_page, which is 2 when comments_count is greater than comments_per_page' do
    stub(@topic).comments_count.returns 15
    @topic.last_page.should == 2
  end
  
  # .previous
  #
  # FIXME make this work, last_updated_at is same with all the topics
  # 
  # test '#previous, returns the previous topic' do
  #   @last_topic.previous.should == @first_topic
  # end

  test 'returns nil if no previous topic exists' do
    @first_topic.previous.should be_nil
  end
  
  # .next
  #
  # FIXME make this work, last_updated_at is same with all the topics
  # 
  # test '#next, returns the next topic' do
  #   @first_topic.next.should == @last_topic
  # end

  test '#next, returns nil if no next topic exists' do
    @last_topic.next.should be_nil
  end

    # describe '#after_comment_update' do
    #   before :each do
    #     @comment = stub_comment
    #     @topic.stub!(:update_attributes!)
    #     @topic.stub!(:destroy)
    #   end
    # 
    #   it 'destroys itself if the comment was destroyed and no more comments exist' do
    #     @comment.stub!(:frozen?).and_return true
    #     @topic.comments.stub!(:last_one).and_return nil
    #     @topic.should_receive(:destroy)
    #     @topic.after_comment_update(@comment)
    #   end
    # 
    #   it 'updates its cache attributes if the comment was saved' do
    #     @topic.comments.stub!(:last_one).and_return nil
    #     @topic.should_receive(:update_attributes!)
    #     @topic.after_comment_update(@comment)
    #   end
    # 
    #   it 'updates its cache attributes if the comment was destroyed but more comments exist' do
    #     @comment.stub!(:frozen?).and_return true
    #     @topic.comments.stub!(:last_one).and_return @comment
    #     @topic.should_receive(:update_attributes!)
    #     @topic.after_comment_update(@comment)
    #   end
    # 
    #   # it 'updates the section by calling after_topic_update' do
    #   #   @topic.section.should_receive(:after_topic_update)
    #   #   @topic.after_comment_update(@comment)
    #   # end
    # end
  
  # .initial_post
  
  test '#initial_post returns the first post of the topic' do
    @topic.initial_post.should == @topic.comments.first
  end
  
  # Protected methods
    
  # .set_site
  
  test '#set_site sets the site from the section' do
    @topic = Topic.new(:section => @forum)
    @topic.send :set_site
    @topic.site.should == @forum.site
  end
end