require File.expand_path(File.dirname(__FILE__) + "/spec_helper.rb")

describe "has_counter:", "using default after_create and after_destroy callbacks" do
  before :each do
    Counter.delete_all
    CounterSpec::Content.delete_all
    CounterSpec::Comment.delete_all

    @content = CounterSpec::Content.create! :title => 'first content'
  end
  
  it "instantiates a counter" do
    @content.comments.create! :text => 'first comment'
    @content.comments_counter.should_not be_nil
  end
  
  it "increments the counter on creation" do
    @content.comments.create! :text => 'first comment'
    @content.comments_count.should == 1
  end
  
  it "decrements the counter on deletion" do
    @comment = @content.comments.create! :text => 'first comment'
    @comment.destroy
    @content.comments_count.should == 0
  end
end

describe "has_counter:", "using a method name as after_create and after_destroy callbacks" do
  before :each do
    Counter.delete_all
    CounterSpec::Content.delete_all
    CounterSpec::Comment.delete_all

    @content = CounterSpec::Content.create! :title => 'first content'
  end
  
  it "instantiates a counter" do
    @content.comments.create! :text => 'first comment'
    @content.approved_comments_counter.should_not be_nil
  end
  
  it "increments the counter on creation" do
    @content.comments.create! :text => 'first comment', :approved => 1
    @content.approved_comments_count.should == 1
  end
  
  it "decrements the counter on deletion" do
    @comment = @content.comments.create! :text => 'first comment', :approved => 1
    @content.approved_comments_count.should == 1
    @comment.destroy
    @content.reload
    @content.approved_comments_count.should == 0
  end
end