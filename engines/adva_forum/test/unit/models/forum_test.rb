require File.expand_path(File.dirname(__FILE__) + '/../../test_helper.rb')

class ForumTest < ActiveSupport::TestCase
  def setup
    super
    @forum = Forum.first
    @topic = @forum.topics.last
    @post  = @forum.posts.last

    # FIXME take the stubbing away
    stub(@topic).last_updated_at.returns(Time.now)
    stub(@post).last_updated_at.returns(Time.now)
  end

  test "is a kind of Section" do
    @forum.should be_kind_of(Section)
  end

  test "has many comments" do
    Forum.should have_many_comments
  end

  test "has a topics counter" do
    Forum.should have_counter(:topics)
  end

  test "has a posts counter" do
    Forum.should have_counter(:posts)
  end

  test "has option topics_per_page" do
    Forum.option_definitions.keys.should include(:topics_per_page)
  end

  test "has option posts_per_page" do
    Forum.option_definitions.keys.should include(:posts_per_page)
  end

  test "has option latest_topics_count" do
    Forum.option_definitions.keys.should include(:latest_topics_count)
  end

  # ASSOCIATIONS

  test "has many boards" do
    @forum.should have_many(:boards)
  end

  test "has many topics" do
    @forum.should have_many(:topics)
  end

  # VALIDATIONS

  # topics_per_page
  test "#topics_per_page, passes when #topics_per_page is numerical" do
    @forum.topics_per_page = 10
    @forum.should be_valid
  end

  test "#topics_per_page, fails when #topics_per_page is not numerical" do
    @forum.topics_per_page = 'ten'
    @forum.should_not be_valid
  end

  # posts_per_page
  test "#posts_per_page, passes when #posts_per_page is numerical" do
    @forum.posts_per_page = 10
    @forum.should be_valid
  end

  test "#posts_per_page, fails when #topics_per_page is not numerical" do
    @forum.posts_per_page = 'ten'
    @forum.should_not be_valid
  end

  # latest_topics_count
  test "#latest_topics_count, passes when #latest_topics_count is numerical" do
    @forum.latest_topics_count = 10
    @forum.should be_valid
  end

  test "#latest_topics_count, fails when #latest_topics_count is not numerical" do
    @forum.latest_topics_count = 'ten'
    @forum.should_not be_valid
  end

  # CLASS METHODS

  # .content_type
  test "Forum#content_type returns 'Topic'" do
    Forum.content_type.should == 'Topic'
  end

  # INSTANCE METHODS

  # .latest_topics
  test "#latest_topics, returns the ten most recently updated topics sorted by updated_at descending" do
    @forum.update_attribute(:latest_topics_count, 1)
    @forum.latest_topics.should == [@topic]
  end

  # .boardless_topics
  test "#boardless_topics, returns the all the forum topics that are not assigned to a board" do
    @forum = Forum.find_by_permalink('a-forum-without-boards')
    @forum.boardless_topics.size.should == @forum.topics.size
  end

  # FIXME just delete these?

  # describe "callbacks" do
  #   it "initializes the topics counter after create" do
  #     Forum.after_create.should include(:set_topics_count)
  #   end
  #
  #   it "initializes the posts counter after create" do
  #     Forum.after_create.should include(:set_posts_count)
  #   end
  # end

  # describe '#after_topic_update' do
  #   before :each do
  #     @forum.topics.stub!(:count)
  #     @forum.posts.stub!(:count)
  #     @forum.stub!(:topics_count).and_return stub_counter
  #     @forum.stub!(:posts_count).and_return stub_counter
  #   end
  #
  #   it "updates the topics counter" do
  #     @forum.topics_count.should_receive(:set).any_number_of_times
  #     @forum.send :after_topic_update, @topic
  #   end
  #
  #   it "updates the posts counter" do
  #     @forum.posts_count.should_receive(:set).any_number_of_times
  #     @forum.send :after_topic_update, @topic
  #   end
  # end
end