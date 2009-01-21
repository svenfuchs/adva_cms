require File.dirname(__FILE__) + '/../spec_helper'

describe Post do
  include FactoryScenario
  
  before :each do
    @post = Post.new
  end
  
  it "is kind of comment" do
    @post.should be_kind_of(Comment)
  end
  
  describe "methods" do
    before :each do
      Site.delete_all
      factory_scenario :forum_with_topics
    end
    
    it "#filter returns the content filter of the forum" do
      @topic.initial_post.filter == @forum.content_filter
    end
  end
end