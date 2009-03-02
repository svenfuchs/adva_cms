require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class BlogCounterTest < ActiveSupport::TestCase
  def setup
    super
    @blog = Blog.find_by_permalink 'a-blog'
    @article = @blog.articles.first
  end

  test "has_one comments_counter" do
    @blog.should have_one(:comments_counter)
  end
  
  test "responds to :comments_count" do
    @blog.should respond_to(:comments_count)
  end
  
  test "after create it has a counter initialized and saved" do
    @blog.comments_counter.should_not be_nil
  end
  
  test "#comments_count is a shortcut to #comments_counter.count" do
    @blog.comments_counter.count = 5
    @blog.comments_count.should == 5
  end
  
  test "increments the counter when a comment has been created" do
    assert_difference('@blog.comments_counter(true).count') do
      create_comment!
    end
  end
  
  test "decrements the counter when a comment has been destroyed" do
    @comment = create_comment!
    assert_difference('@blog.comments_counter(true).count', -1) do
      @comment.section.comments_counter.reload # hmmmm ...
      @comment.destroy
    end
  end
  
  def create_comment!
    @blog.comments.create! :section => @blog, :body => 'body', :author => User.first, :commentable => @article
  end
end
