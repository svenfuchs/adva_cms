require File.dirname(__FILE__) + '/../spec_helper'

describe Topic do
  before :each do
    @post = Post.new
  end
  
  it "is kind of comment" do
    @post.should be_kind_of(Comment)
  end
end