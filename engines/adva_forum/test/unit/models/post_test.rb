require File.expand_path(File.dirname(__FILE__) + '/../../test_helper.rb')

class PostTest < ActiveSupport::TestCase
  def setup
    super
    @post = Post.first
  end
  
  test "is kind of comment" do
    @post.should be_kind_of(Comment)
  end
end