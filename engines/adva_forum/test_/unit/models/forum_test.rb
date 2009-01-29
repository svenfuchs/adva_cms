require File.expand_path(File.dirname(__FILE__) + '/../../test_helper.rb')

class ForumTest < ActiveSupport::TestCase
  def setup
    super
    @forum    = Forum.first
    @topic    = @forum.topics.last
    @comment  = @forum.comments.last
    
    # FIXME take the stubbing away
    stub(@topic).last_updated_at.returns Time.now
    stub(@comment).last_updated_at.returns Time.now
  end
  
  test "is a kind of Section" do
    @forum.should be_kind_of(Section)
  end

  test "acts as a commentable" do
    Forum.should act_as_commentable
  end

  test "has a topics counter" do
    Forum.should have_counter(:topics)
  end

  test "has a comments counter" do
    Forum.should have_counter(:comments)
  end
  
  test "has option topics_per_page" do
    Forum.option_definitions.keys.should include(:topics_per_page)
  end
  
  test "has option comments_per_page" do
    Forum.option_definitions.keys.should include(:comments_per_page)
  end
  
  test "has option latest_topics_count" do
    Forum.option_definitions.keys.should include(:latest_topics_count)
  end
  
  # Associations
  
  test "has many boards" do
    @forum.should have_many(:boards)
  end

  test "has many topics" do
    @forum.should have_many(:topics)
  end

  test "has one recent topic" do
    @forum.should have_one(:recent_topic)
  end

  test "has one recent comment" do
    @forum.should have_one(:recent_comment)
  end
  
  # Validations
  
  # topics_per_page
  
  test "#topics_per_page, passes when #topics_per_page is numerical" do
    @forum.topics_per_page = 10
    @forum.valid?.should be_true
  end
  
  test "#topics_per_page, fails when #topics_per_page is not numerical" do
    @forum.topics_per_page = 'ten'
    @forum.valid?.should be_false
  end
  
  # comments_per_page
  
  test "#comments_per_page, passes when #comments_per_page is numerical" do
    @forum.comments_per_page = 10
    @forum.valid?.should be_true
  end
  
  test "#comments_per_page, fails when #topics_per_page is not numerical" do
    @forum.comments_per_page = 'ten'
    @forum.valid?.should be_false
  end

  # latest_topics_count

  test "#latest_topics_count, passes when #latest_topics_count is numerical" do
    @forum.latest_topics_count = 10
    @forum.valid?.should be_true
  end
  
  test "#latest_topics_count, fails when #latest_topics_count is not numerical" do
    @forum.latest_topics_count = 'ten'
    @forum.valid?.should be_false
  end
  
  # Class methods
    
  # .content_type
  
  test "Forum#content_type returns 'Board'" do
    Forum.content_type.should == 'Board'
  end
  
  # Methods
  
  # .recent_topic
  
  test "#recent_topic, returns the most recent topic" do
    @forum.recent_topic.should == @topic
  end
  
  # .recent_comment
    
  test "#recent_comment, returns the most recent comment" do
    @forum.recent_comment.should == @comment
  end
    
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
  
  # FIXME just delete these away?
  
  # describe "callbacks" do
  #   it "initializes the topics counter after create" do
  #     Forum.after_create.should include(:set_topics_count)
  #   end
  #   
  #   it "initializes the comments counter after create" do
  #     Forum.after_create.should include(:set_comments_count)
  #   end
  # end

  # describe '#after_topic_update' do
  #   before :each do
  #     @forum.topics.stub!(:count)
  #     @forum.comments.stub!(:count)
  #     @forum.stub!(:topics_count).and_return stub_counter
  #     @forum.stub!(:comments_count).and_return stub_counter
  #   end
  #
  #   it "updates the topics counter" do
  #     @forum.topics_count.should_receive(:set).any_number_of_times
  #     @forum.send :after_topic_update, @topic
  #   end
  #
  #   it "updates the comments counter" do
  #     @forum.comments_count.should_receive(:set).any_number_of_times
  #     @forum.send :after_topic_update, @topic
  #   end
  # end
end