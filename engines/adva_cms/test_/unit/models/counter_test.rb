require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class CounterTest < ActiveSupport::TestCase
  def setup
    super
    @forum = Forum.first
  end

  test "has_one topics_count" do
    @forum.should have_one(:topics_counter)
  end

  test "responds to :topics_count" do
    # FIXME add matcher
    # @forum.should respond_to(:topics_count)
    assert @forum.respond_to?(:topics_count)
  end
  
  test "after create it has a counter initialized and saved" do
    @forum.topics_counter.should_not be_nil
  end
  
  test "#topics_count is a shortcut to #topics_counter.count" do
    @forum.topics_counter.count = 5
    @forum.topics_count.should == 5
  end
  
  test "increments the counter when a topic has been created" do
    assert_difference('@forum.topics_counter.count') do
      create_topic!
    end
  end
  
  test "decrements the counter when a topic has been created" do
    @topic = create_topic!
    assert_difference('@forum.topics_counter.count', -1) do
      @topic.destroy
    end
  end
  
  def create_topic!
    @forum.topics.create! :section => @forum, :title => 'title', :body => 'body', :author => User.first
  end
end
