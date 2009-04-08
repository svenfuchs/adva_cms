require File.expand_path(File.dirname(__FILE__) + '/../../test_helper.rb')

class ForumHelperTest < ActionView::TestCase
  include ForumHelper

	def setup
	  super
	  @topic = Topic.first
	  # FIXME find a way to remove stubbing

    @controller = TestController.new
    @request = ActionController::TestRequest.new

    @topic_path = @controller.send(:topic_path, @topic.section, @topic.permalink)
    @previous_topic_path = @controller.send(:previous_topic_path, @topic.section, @topic.permalink)
    @next_topic_path = @controller.send(:next_topic_path, @topic.section, @topic.permalink)
	end
	
	# .confirm_board_delete
	# FIXME add tests
	
	# .forum_boards_select
	# FIXME add tests
	
	# .link_to_topic
  test "#link_to_topic, links to the given topic" do
    link_to_topic(@topic).should have_tag('a[href^=?]', @topic_path)
  end

  test "#link_to_topic, given no String preceeds the topic in the argument list it uses the topic's title as link text" do
    link_to_topic(@topic).should =~ Regexp.new(@topic.title)
  end

  test "#link_to_topic, given a String preceeding the topic in the argument list uses the String as link text" do
    link_to_topic('link text', @topic).should =~ /link text/
  end
  
  # .link_to_last_post
  test "#link_to_last_post, links to the last post of a topic" do
    last_post_id = @topic.last_post.id
    link_to_last_post(@topic).should have_tag('a[anchor^=?]', "comment_#{last_post_id}")
  end

  test "#link_to_last_post, given no String preceeds the topic in the argument list it uses the last post's created_at date as link text" do
    link_to_last_post(@topic).should =~ /[\w]+ [\d]+, [\d]+\ [\d]+\:[\d]+/
  end

  test "#link_to_last_post, given a String preceeding the topic in the argument list uses the String as link text" do
    link_to_last_post('link text', @topic).should =~ /link text/
  end
  
  # .link_to_prev_topic
  test "#link_to_prev_topic, links to the previous topic" do
    link_to_prev_topic(@topic).should have_tag('a[href=?]', @previous_topic_path)
  end

  test "#link_to_prev_topic, given no String preceeds the topic in the argument list it uses '&larr; previous' as link text" do
    link_to_prev_topic(@topic).should =~ /&larr; previous/
  end

  test "#link_to_prev_topic, given a String preceeding the topic in the argument list uses the String as link text" do
    link_to_prev_topic('link text', @topic).should =~ /link text/
  end

  test "#link_to_prev_topic, given a :format option interpolates the links to it" do
    link_to_prev_topic(@topic, {:format => '<b>%s</b>'}).should =~ %r(<b>.*</b>)
  end
  
  # .link_to_next_topic
  test "#link_to_next_topic, links to the next topic" do
    link_to_next_topic(@topic).should have_tag('a[href=?]', @next_topic_path)
  end

  test "#link_to_next_topic, given no String preceeds the topic in the argument list it uses 'next &rarr;' as link text" do
    link_to_next_topic(@topic).should =~ /next &rarr;/
  end

  test "#link_to_next_topic, given a String preceeding the topic in the argument list uses the String as link text" do
    link_to_next_topic('link text', @topic).should =~ /link text/
  end

  test "#link_to_next_topic, given a :format option interpolates the links to it" do
    link_to_next_topic(@topic, {:format => '<b>%s</b>'}).should =~ %r(<b>.*</b>)
  end
  
  # .links_to_prev_next_topics
  test "#links_to_prev_next_topics, returns links to the the previous and next topics" do
    links_to_prev_next_topics(@topic).should have_tag('a[href=?]', @previous_topic_path)
    links_to_prev_next_topics(@topic).should =~ /&larr; previous/
    links_to_prev_next_topics(@topic).should have_tag('a[href=?]', @next_topic_path)
    links_to_prev_next_topics(@topic).should =~ /next &rarr/
  end
  
  test "#links_to_prev_next_topics, given no :separator option it uses a space to join the links" do
    expected = %(<a href="#{@previous_topic_path}">&larr; previous</a> <a href="#{@next_topic_path}">next &rarr;</a>)
    links_to_prev_next_topics(@topic).should == expected
  end
  
  test "#links_to_prev_next_topics, given an option :separator it uses that to join the links" do
    expected = %(<a href="#{@previous_topic_path}">&larr; previous</a> + <a href="#{@next_topic_path}">next &rarr;</a>)
    links_to_prev_next_topics(@topic, :separator => ' + ').should == expected
  end
  
  test "given a :format option interpolates the links to it" do
    expected = %(<b><a href="#{@previous_topic_path}">&larr; previous</a> <a href="#{@next_topic_path}">next &rarr;</a></b>)
    links_to_prev_next_topics(@topic, :format => '<b>%s</b>').should == expected
  end
  
  # .topic_attributes
  test "#topic_attributes, returns comma-joined meta data about the topic including the number of posts" do
    topic_attributes(@topic).should =~ /\d+ post(s)?/i
  end
  
  test "#topic_attributes, given that the topic is sticky also includes the string 'sticky'" do
    @topic.update_attribute(:sticky, 1)
    topic_attributes(@topic).should =~ /sticky/i
  end
  
  test "#topic_attributes, given that the topic is not sticky does not include the string 'sticky'" do
    topic_attributes(@topic).should_not =~ /sticky/i
  end
  
  test "#topic_attributes, given that the topic is locked also includes the string 'locked'" do
    @topic.update_attribute(:locked, 1)
    topic_attributes(@topic).should =~ /locked/i
  end
  
  test "#topic_attributes, given that the topic is not locked does not include the string 'locked'" do
    topic_attributes(@topic).should_not =~ /locked/i
  end
  
  test "#topic_attributes, given a format_string as second argument it interpolates the result to it" do
    topic_attributes(@topic, '<b>%s</b>').should !~ %r(<b>.*</b>)
  end
end