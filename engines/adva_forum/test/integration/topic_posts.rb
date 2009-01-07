require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper' ))

class TopicPosts < ActionController::IntegrationTest
  def setup
    factory_scenario  :site_with_forum
    login_as          :admin
    @board  = Factory :board, :site => @site, :section => @forum
    @topic  = @forum.topics.post(@user, Factory.attributes_for(:topic, :section => @forum, :board => @board))
    @topic.save
  end
  
  def test_an_admin_creates_a_new_post_to_a_topic
     # Go to section
    get forum_path(@forum)
    
    # Admin clicks link to go to the board
    click_link @board.title
    
    # Admin clicks link to go to the topic
    click_link @topic.title
    assert Post.count == 1
    
    assert_template 'topics/show'
    
    fill_in       'post[body]', :with => 'Test post body'
    click_button  'Submit post'
    
    assert Post.count == 2
    
    assert_template 'topics/show'
  end
end