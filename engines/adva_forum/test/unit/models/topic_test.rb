require File.expand_path(File.dirname(__FILE__) + '/../../test_helper.rb')

class TopicTest < ActiveSupport::TestCase
  def setup
    super
    @user = User.first
    @topic = Topic.find_by_title('a board topic')
    @last_topic = Topic.find_by_title('another board topic')
    @forum = @topic.section

    stub(@topic).last_updated_at.returns(3.months.ago)
    stub(@last_topic).last_updated_at.returns(1.second.ago)
  end

  test "delegates comment_filter to a site" do
    @topic.comment_filter.should == @forum.site.comment_filter
  end

  # Class extensions

  test "has a permalink generated from the title" do
    Topic.should have_permalink(:title)
  end

  test 'acts as a role context' do
    Topic.should act_as_role_context(:parent => Board)
  end

  # test 'specifies implicit roles (author roles for posts)' do
  #   @topic.should respond_to(:implicit_roles)
  # end

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

  test 'belongs to a last post' do
    @topic.should belong_to(:last_post)
  end

  test 'belongs to a author' do
    @topic.should belong_to(:author)
  end

  test 'belongs to a last_author' do
    @topic.should belong_to(:last_author)
  end

  test 'have many posts' do
    @topic.respond_to?(:posts).should be_true
  end

  test "has a posts counter" do
    Topic.should have_counter(:posts)
  end

  # Callbacks

  test 'sets the site before validation' do
    Topic.before_validation.should include(:set_site)
  end

  # Validations

  test 'validates the presence of a section' do
    @topic.board = nil # sets section from board before_validate, so remove that one, too
    @topic.should validate_presence_of(:section)
  end

  test 'validates the presence of a title' do
    @topic.should validate_presence_of(:title)
  end

  test 'validates the presence of a body on create' do
    @topic = Topic.new # validates on create, needs a new Topic object for it
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
    forum.topics.first.should be_owned_by(forum)
  end

  test '#owner returns a board, when topic is on board forum' do
    forum = Forum.find_by_permalink('a-forum-with-boards')
    topic = forum.topics.first
    topic.should be_owned_by(topic.board)
  end

  # .reply

  test '#reply, builds a new post with the given attributes' do
    post = @topic.reply(@user, :body => 'body')
    post.should be_kind_of(Post)
  end

  test '#reply, sets the post author' do
    post = @topic.reply(@user, :body => 'body')
    post.author.should == @user
  end

  test '#reply, sets the board' do
    post = @topic.reply(@user, :body => 'body')
    post.board.should == @topic.board
  end

  test '#reply, sets itself as the topic' do
    post = @topic.reply(@user, :body => 'body')
    post.topic.should == @topic
  end

  test '#reply, returns a valid post when a valid, new author and a body were given' do
    post = @topic.reply(@user, :body => 'body')
    lambda { post.save! }.should_not raise_error
  end

  # .update_attributes

  # works the same way as update_attributes does, but also uses move_to_board when a board_id was given
  test "#update_attributes moves the topic's posts when the topic's board_id is changed" do
    @topic.update_attributes(:title => 'foo', :board_id => 1)
    @topic.title.should == 'foo'
    @topic.posts.each do |post|
      post.board_id.should == 1
    end
  end

  # .accept_comments?

  test '#accept_comments?, returns true when it is not locked' do
    @topic.should accept_comments
  end

  test '#accept_comments?, returns false when it is locked' do
    @topic.update_attribute(:locked, 1)
    @topic.should_not accept_comments
  end

  # .paged?

  test '#paged?, returns true when the posts_count is greater than the posts_per_page attribute of the section' do
    stub(@topic).posts_count.returns(150)
    @topic.should be_paged
  end

  test '#paged?, returns false when the posts_count is not greater than the posts_per_page attribute of the section' do
    stub(@topic).posts_count.returns(5)
    @topic.should_not be_paged
  end

  # .page

  test 'page returns 1 for the first post on page 1' do
    @topic.section.update_attributes(:posts_per_page => 2)
    post = @topic.posts.first
    post.page.should == 1
  end

  test 'page returns 1 for the last post on page 1' do
    @topic.section.update_attributes(:posts_per_page => 2)
    post = @topic.posts.second
    post.page.should == 1
  end

  test 'page returns 1 for the first post on page 2' do
    @topic.section.update_attributes(:posts_per_page => 2)
    post = @topic.posts.third
    post.page.should == 2
  end

  test 'page returns 2 for the last post on page 2' do
    @topic.section.update_attributes(:posts_per_page => 2)
    post = @topic.posts.last
    post.page.should == 2
  end

  # .last_page

  test '#last_page, which is 1 when posts_count is 0' do
    stub(@topic).posts_count.returns(0)
    @topic.last_page.should == 1
  end

  test '#last_page, which is 1 when posts_count is lesser than posts_per_page' do
    stub(@topic).posts_count.returns(5)
    @topic.last_page.should == 1
  end

  test '#last_page, which is 1 when posts_count equals posts_per_page' do
    stub(@topic).posts_count.returns(10)
    @topic.last_page.should == 1
  end

  test '#last_page, which is 2 when posts_count is greater than posts_per_page' do
    stub(@topic).posts_count.returns(15)
    @topic.last_page.should == 2
  end

  # .previous

  test '#previous, returns the previous topic' do
    @last_topic.previous.should == @topic
  end

  test 'returns nil if no previous topic exists' do
    @topic.previous.should be_nil
  end

  # .next
  #
  test '#next, returns the next topic' do
    @topic.next.should == @last_topic
  end

  test '#next, returns nil if no next topic exists' do
    @last_topic.next.should be_nil
  end

  test 'destroys itself if the post was destroyed and no more comments exist' do
    post = @topic.posts.first
    stub(post).frozen?.returns(true)
    stub(@topic.posts).last.returns(nil)
    @topic.after_post_update(post)
    @topic.should be_frozen
  end

  test 'updates its cache attributes if the post was saved' do
    post = @topic.posts.first
    stub(post).frozen?.returns(false)
    mock(@topic).update_attributes!(:last_updated_at => post.created_at, :last_post_id => post.id, :last_author => post.author)
    @topic.after_post_update(post)
  end

  test 'updates its cache attributes if the comment was destroyed but another comment still exists' do
    post = @topic.posts.first
    last = @topic.posts.last
    stub(post).frozen?.returns(true)
    mock(@topic).update_attributes!(:last_updated_at => last.created_at, :last_post_id => last.id, :last_author => last.author)
    @topic.after_post_update(post)
  end

  # .initial_post

  test '#initial_post returns the first post of the topic' do
    @topic.initial_post.should == @topic.posts.first
  end

  # Protected methods

  # .set_site

  test '#set_site sets the site from the section' do
    @topic = Topic.new(:section => @forum)
    @topic.send(:set_site)
    @topic.site.should == @forum.site
  end
end