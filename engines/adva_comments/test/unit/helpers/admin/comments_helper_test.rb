require File.dirname(__FILE__) + '/../../../test_helper'

class AdminCommentsHelperTest < ActionView::TestCase
  include Admin::CommentsHelper
  
  test "translates comment_expiration_options" do
    expected = [ ['Are not allowed',                     -1],
                 ['Never expire',                         0],
                 ['Expire 24 hours after publishing',     1],
                 ['Expire 1 week after publishing',       7],
                 ['Expire 1 month after publishing',      30],
                 ['Expire 3 months after publishing',     90] ]
    comment_expiration_options.should == expected
  end
  
  test "translates comments_filter_options" do
    lambda { comments_filter_options }.should_not raise_error
  end
  
  test "translates comments_state_options" do
    lambda { comments_state_options }.should_not raise_error
  end
end