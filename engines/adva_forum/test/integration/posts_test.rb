require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper' ))

class PostsTest < ActionController::IntegrationTest
  def setup
    super
    @site = use_site! 'site with forum'
  end
  
  test 'an admin replies to a topic' do
    login_as_admin
    visit_the_forum
    visit_the_topic
    reply_to_topic
  end
  
  test 'an admin deletes an existing topic post' do
    login_as_superuser  # FIXME change to admin when ticket #219 is fixed!
    visit_the_forum
    visit_the_topic
    delete_the_reply
  end
  
  test 'an admin edits an existing topic post' do
    login_as_superuser  # FIXME change to admin when ticket #219 is fixed!
    visit_the_forum
    visit_the_topic
    edit_the_post
  end
  
  def visit_the_forum
    @forum = Forum.find_by_permalink 'a-forum-without-boards'
    
    get '/a-forum-without-boards'
    renders_template "forum/show"
  end
  
  def visit_the_topic
    @topic = @forum.topics.find_by_permalink('a-topic')
    
    click_link @topic.title
    assert_template 'topics/show'
  end
  
  def reply_to_topic
    @topic.posts.reload # ? why is it 0 here otherwise?
    post_count = @topic.posts.size
    
    assert_template 'topics/show'
    fill_in       'post[body]', :with => 'Test post body'
    click_button  'Submit post'
    
    @topic.posts.reload
    assert @topic.posts.size == post_count + 1
    assert_template 'topics/show'
  end
  
  def delete_the_reply
    @topic.posts.reload # otherwise count is 0. why?
    post_count = @topic.posts.size
    post = @topic.posts.find_by_body('a reply')

    click_link  "delete_post_#{post.id}"
    
    @topic.posts.reload
    assert @topic.posts.size == post_count - 1
    assert_template 'topics/show'
  end
  
  def edit_the_post
    post = @topic.posts.find_by_body('a reply')
    assert post.body != 'Updated test post'
    
    click_link "edit_post_#{post.id}"
    
    assert_template 'posts/edit'
    fill_in       'post[body]', :with => 'Updated test post'
    click_button  'Save post'
    
    assert_template 'topics/show'
    post.reload
    assert post.body == 'Updated test post'
  end
end