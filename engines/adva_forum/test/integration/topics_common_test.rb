require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper' ))

class TopicsCommon < ActionController::IntegrationTest
  def setup
    # Note to self! (Again) login_as deletes all the users, so post.author
    # does not work anymore. Thats why it has to come before scenario.
    login_as          :admin
    factory_scenario  :forum_with_topics
  end

  test "01  an admin edits the existing topic" do
    assert @topic.title != 'Updated test topic'

    # Go to section
    get forum_path(@forum)

    # Admin clicks link to go to the board
    click_link @topic.title
    assert_template 'topics/show'

    click_link "topic_#{@topic.id}_edit"

    fill_in       'Title', :with => 'Updated test topic'
    click_button  'Save'

    assert_template 'topics/show'
    @topic.reload
    assert_equal "Updated test topic", @topic.title
  end

  test "02 an admin makes the topic sticky" do
    # Go to section
    get forum_path(@forum)

    # Admin clicks link to go to the board
    click_link @topic.title
    assert_template 'topics/show'

    click_link "topic_#{@topic.id}_edit"

    check         'Sticky'
    click_button  'Save'

    assert_template 'topics/show'
    @topic.reload
    assert @topic.sticky?
  end

  test "03 an admin locks the topic" do
    # Go to section
    get forum_path(@forum)

    # Admin clicks link to go to the board
    click_link @topic.title
    assert_template 'topics/show'

    click_link "topic_#{@topic.id}_edit"

    check         'Locked'
    click_button  'Save'

    assert_template 'topics/show'
    @topic.reload
    assert @topic.locked?
  end

  test "04 an admin deletes the existing topic" do
    # Go to section
    get forum_path(@forum)

    # Admin clicks link to go to the board
    click_link @topic.title
    assert_template 'topics/show'

    assert Topic.count == 2

    click_link "topic_#{@topic.id}_delete"

    assert_template 'forum/show'
    assert Topic.count == 1
  end
  
  test "05 an admin goes to previous topic when on first topic" do
    # Go to section
    get forum_path(@forum)
  
    # Admin clicks link to go to the board
    click_link @forum.topics(true).first.title
    assert_template 'topics/show'
  
    click_link 'previous'
  
    assert_template 'topics/show'
    assert_flash  'There is no previous topic'
  end

  test "06 an admin goes to previous topic when on last topic" do
    # Go to section
    get forum_path(@forum)

    # Admin clicks link to go to the board
    click_link @forum.topics(true).last.title
    assert_template 'topics/show'

    click_link 'previous'

    assert_template 'topics/show'

    assert_select "div#main" do
    assert_select "h2", /Test topic/
    end
  end

  test "07 an admin goes to next topic when on last topic" do
    # Go to section
    get forum_path(@forum)

    # Admin clicks link to go to the board
    click_link @forum.topics(true).last.title
    assert_template 'topics/show'

    click_link 'next'

    assert_template 'topics/show'
    assert_flash  'There is no next topic'
  end

  test "08 an admin goes to next topic when on first topic" do
    # Go to section
    get forum_path(@forum)

    # Admin clicks link to go to the board
    click_link @forum.topics(true).first.title
    assert_template 'topics/show'

    click_link 'next'

    assert_template 'topics/show'

    assert_select "div#main" do
    assert_select "h2", /Test topic/
    end
  end
end