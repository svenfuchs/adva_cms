require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::CommentsHelper do
  it "translates comment_expiration_options" do
    expected = [ ['Are not allowed',                     -1],
                 ['Never expire',                         0],
                 ['Expire 24 hours after publishing',     1],
                 ['Expire 1 week after publishing',       7],
                 ['Expire 1 month after publishing',      30],
                 ['Expire 3 months after publishing',     90] ]
    helper.comment_expiration_options.should == expected
  end
  
  it "translates comments_filter_options" do
    lambda { helper.comments_filter_options }.should_not raise_error
  end
  
  it "translates comments_state_options" do
    lambda { helper.comments_state_options }.should_not raise_error
  end
end