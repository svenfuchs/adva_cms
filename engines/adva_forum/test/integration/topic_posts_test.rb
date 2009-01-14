require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper' ))

class TopicPosts < ActionController::IntegrationTest
  def setup
    factory_scenario  :site_with_forum
    login_as          :admin
    @topic  = @forum.topics.post(@user, Factory.attributes_for(:topic, :section => @forum))
    @topic.save
  end
  
  def test_an_admin_creates_a_new_post_to_a_topic
     # Go to section
    get forum_path(@forum)
    
    # Admin clicks link to go to the topic
    click_link @topic.title
    assert Post.count == 1
    
    assert_template 'topics/show'
    
    fill_in       'post[body]', :with => 'Test post body'
    click_button  'Submit post'
    
    assert Post.count == 2
    
    assert_template 'topics/show'
  end
  
  def test_an_admin_deletes_an_existing_topic_post
    post = @topic.reply(@user, :body => 'Delete me')
    post.save
     # Go to section
    get forum_path(@forum)
    
    # Admin clicks link to go to the topic
    click_link @topic.title
    
    assert_template 'topics/show'
    assert @topic.comments.size == 2
    
    click_link  "delete_comment_#{post.id}"
    
    @topic.comments.reload
    assert @topic.comments.size == 1
    
    assert_template 'topics/show'
  end
  
  def test_an_admin_edits_an_existing_topic_post
     # Go to section
    get forum_path(@forum)
    
    # Admin clicks link to go to the topic
    click_link @topic.title
    assert_template 'topics/show'
    
    # Admin clicks link to go to the post edit form
    click_link "edit_comment_#{@topic.initial_post.id}"
    assert @topic.initial_post.body != 'Updated test post'
    
    assert_template 'posts/edit'
    fill_in       'post[body]', :with => 'Updated test post'
    click_button  'Save post'
    
    assert_template 'topics/show'
    @topic.initial_post.reload
    assert @topic.initial_post.body == 'Updated test post'
  end
end