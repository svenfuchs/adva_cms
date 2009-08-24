require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class WikiCounterTest < ActiveSupport::TestCase
  def setup
    super
    @wiki = Wiki.find_by_permalink('a-wiki')
    @wikipage = @wiki.wikipages.first
  end

  test "has_one comments_counter" do
    @wiki.should have_one(:comments_counter)
  end

  test "responds to :comments_count" do
    @wiki.should respond_to(:comments_count)
  end

  test "after create it has a counter initialized and saved" do
    @wiki.comments_counter.should_not be_nil
  end

  test "#comments_count is a shortcut to #comments_counter.count" do
    @wiki.comments_counter.count = 5
    @wiki.comments_count.should == 5
  end

  test "increments the counter when a comment has been created" do
    assert_difference('@wiki.comments_counter(true).count') do
      create_comment!
    end
  end

  test "decrements the counter when a comment has been destroyed" do
    @comment = create_comment!
    assert_difference('@wiki.comments_counter(true).count', -1) do
      @comment.section.comments_counter.reload # hmmmm ...
      @comment.destroy
    end
  end

  def create_comment!
    @wiki.comments.create!(:section => @wiki, :body => 'body', :author => User.first, :commentable => @wikipage)
  end
end
