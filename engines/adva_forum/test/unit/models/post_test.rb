require File.expand_path(File.dirname(__FILE__) + '/../../test_helper.rb')

class PostTest < ActiveSupport::TestCase
  def setup
    super
    @post = Post.find_by_body('another reply')
    @topic = @post.topic
  end

  # CALLBACKS

  test 'updates the topic after create' do
    Post.after_save.should include(:update_caches)
  end

  test 'updates the topic after destroy' do
    Post.after_destroy.should include(:update_caches)
  end

  # INSTANCE METHODS

  test '#update_caches calls #after_post_update on the topic' do
    mock(@post.topic.target).after_post_update(@post)
    @post.send(:update_caches)
  end

  test 'previous returns the previous post' do
    @post.previous.should == @topic.posts.find_by_body('a reply')
  end
end