require File.dirname(__FILE__) + '/../spec_helper'

describe Topic do
  before :each do
    @post = Post.new
  end
  
  it "is kind of comment" do
    @post.should be_kind_of(Comment)
  end
  
  describe "callbacks:" do
    it 'decrements the section counter before destroy' do
      Topic.before_destroy.should include(:decrement_counter)
    end
  end
  
  describe "protected methods" do
    before :each do
      @site   = Factory :site
      @forum  = Factory :forum, :site => @site
      @post.stub!(:section).and_return @forum
      @forum.comments_counter.set(1)
    end
    
    it "decrements the section counter" do
      @post.send :decrement_counter
      @forum.comments_count.should == 0
    end
  end
end