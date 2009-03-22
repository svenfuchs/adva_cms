require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper' ))

class TopicsTest < ActionController::IntegrationTest
  def setup
    super
    @site = use_site! 'site with forum'
  end

  test "an admin edits the existing topic" do
    login_as_admin
    visit_the_forum
    visit_the_topic
    edit_the_topic_and_submit_the_form
  end

  test "an admin makes the topic sticky" do
    login_as_admin
    visit_the_forum
    visit_the_topic
    sticky_the_topic_and_submit_the_form
  end

  test "an admin locks the topic" do
    login_as_admin
    visit_the_forum
    visit_the_topic
    lock_the_topic_and_submit_the_form
  end

  test "an admin deletes the existing topic" do
    login_as_admin
    visit_the_forum
    visit_the_topic
    delete_the_topic
  end
  
  # FIXME first and last topic are randomized because last_updated_at
  #       time is exactly the same
  #
  # test "an admin clicks the 'previous' link when on the first topic" do
  #   login_as_admin
  #   visit_the_forum
  #   visit_the_topic
  #   click_link 'previous'
  #   display_first_topic
  # end
  # 
  # test "an admin clicks the 'previous' link when on the last topic" do
  #   login_as_admin
  #   visit_the_forum
  #   visit_the_last_topic
  #   click_link 'previous'
  #   display_previous_topic
  # end
  # 
  # test "an admin clicks the 'next' link when on the last topic" do
  #   login_as_admin
  #   visit_the_forum
  #   visit_the_last_topic
  #   click_link 'next'
  #   display_last_topic
  # end
  # 
  # test "an admin clicks the 'next' link when on the first topic" do
  #   login_as_admin
  #   visit_the_forum
  #   visit_the_topic
  #   click_link 'next'
  #   display_next_topic
  # end
  
  def visit_the_forum
    @forum = Forum.find_by_permalink 'a-forum-with-two-topics'
    
    get '/a-forum-with-two-topics'
    renders_template "forum/show"
  end
  
  def visit_the_topic
    @topic = @forum.topics.find_by_permalink('first-topic')
    
    click_link @topic.title
    assert_template 'topics/show'
  end
  
  def visit_the_last_topic
    @topic = @forum.topics.find_by_permalink('last-topic')
    
    click_link @topic.title
    assert_template 'topics/show'
  end
  
  def edit_the_topic_and_submit_the_form
    click_link "edit_topic_#{@topic.id}"
    assert @topic.title != 'Updated test topic'

    fill_in         'Title', :with => 'Updated test topic'
    click_button    'Save'
    assert_template 'topics/show'
    
    @topic.reload
    assert_equal "Updated test topic", @topic.title
  end
  
  def sticky_the_topic_and_submit_the_form
    click_link "edit_topic_#{@topic.id}"

    check           'Sticky'
    click_button    'Save'
    assert_template 'topics/show'
    
    @topic.reload
    assert @topic.sticky?
  end
  
  def lock_the_topic_and_submit_the_form
    click_link "edit_topic_#{@topic.id}"

    check           'Locked'
    click_button    'Save'
    assert_template 'topics/show'
    
    @topic.reload
    assert @topic.locked?
  end
  
  def delete_the_topic
    topic_count = @forum.topics.size

    click_link "delete_topic_#{@topic.id}"
    assert_template 'forum/show'
    
    @forum.reload
    assert @forum.topics.size == topic_count - 1
  end
  
  def display_previous_topic
    assert_template 'topics/show'

    assert_select "div#main" do
      assert_select "h2", /first topic/
    end
  end
  alias display_first_topic display_previous_topic
  
  def display_next_topic
    assert_template 'topics/show'

    assert_select "div#main" do
      assert_select "h2", /last topic/
    end
  end
  alias display_last_topic display_next_topic
end