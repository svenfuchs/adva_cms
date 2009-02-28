require File.expand_path(File.dirname(__FILE__) + '/../../test_helper.rb')

class PostTest < ActiveSupport::TestCase
  def setup
    super
    @post = Post.first
  end
  
  test "is kind of comment" do
    @post.should be_kind_of(Comment)
  end
  
  # CALLBACKS
  
  test 'updates the commentable after create' do
    Post.after_save.should include(:update_commentable)
  end
  
  test 'updates the commentable after destroy' do
    Post.after_destroy.should include(:update_commentable)
  end
  
  # update_commentable
  
  test '#update_commentable calls #after_comment_update on the commentable' do
    mock(@post.commentable.target).after_comment_update(@post)
    @post.send :update_commentable
  end
end