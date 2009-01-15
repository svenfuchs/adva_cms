require File.dirname(__FILE__) + '/../spec_helper'

describe PostsController do
  include SpecControllerHelper
  include FactoryScenario
  
  before :each do
    Site.delete_all
    factory_scenario :forum_with_topics
    @post = Factory(:post, :author => @user, :commentable => @topic)
    @topic.reload; @forum.reload  # wtf ! TODO there is something wrong with setup
    
    Site.stub!(:find_by_host).and_return @site
    @site.sections.stub!(:find).and_return @forum
    controller.stub!(:current_user).and_return @user
  end
  
  it "should be a BaseController" do
    controller.should be_kind_of(BaseController)
  end
  
  describe "GET to new" do
    before :each do
      Post.stub!(:new).and_return @post
    end
    act! { request_to :get, "/forums/#{@forum.id}/topics/#{@topic.id}/posts/new" }
    it_assigns :post
  end
  
  describe "GET to edit" do
    before :each do
      @topic.comments.stub!(:find).and_return @post
    end
    act! { request_to :get, "/forums/#{@forum.id}/topics/#{@topic.id}/posts/#{@post.id}/edit" }
    it_assigns @post
  end
  
  describe "POST to create" do
    before :each do
      @forum.topics.stub!(:find).and_return @topic
      @topic.stub!(:reply).and_return @post
    end
    act! { request_to :post, "/forums/#{@forum.id}/topics/#{@topic.id}/posts", {} }
    
    it "instantiates a new post through topic.reply" do
      @topic.should_receive(:reply).with(@user, nil).and_return(@post)
      act!
    end
    
    describe "with valid parameters" do
      it_redirects_to { "http://test.host/forums/#{@forum.id}/topics/#{@topic.permalink}#post_#{@post.id}" }
      it_assigns_flash_cookie :notice => :not_nil
      
      it "saves the post" do
        @post.should_receive(:save).and_return true
        act!
      end
    end
    
    describe "with invalid parameters" do
      before :each do
        @post.stub!(:save).and_return false
      end
      it_renders_template :new
      it_assigns_flash_cookie :error => :not_nil
    end
  end
  
  describe "PUT to update" do
    before :each do
      @forum.topics.stub!(:find).and_return @topic
      @topic.comments.stub!(:find).and_return @post
    end
    act! { request_to :put, "/forums/#{@forum.id}/topics/#{@topic.id}/posts/#{@post.id}", {} }
    
    describe "with valid parameters" do
      it_redirects_to { "http://test.host/forums/#{@forum.id}/topics/#{@topic.permalink}#post_#{@post.id}" }
      it_assigns_flash_cookie :notice => :not_nil
      
      it "updates the post" do
        @post.should_receive(:update_attributes).and_return true
        act!
      end
    end
    
    describe "with invalid parameters" do
      before :each do
        @post.stub!(:update_attributes).and_return false
      end
      it_renders_template :edit
      it_assigns_flash_cookie :error => :not_nil
    end
  end
  
  describe "DELETE to destroy" do
    describe "with normal posts" do
      before :each do
        @topic.comments.stub!(:find).and_return @post
        @topic.stub!(:initial_post).and_return Comment.new
      end
      act! { request_to :delete, "/forums/#{@forum.id}/topics/#{@topic.id}/posts/#{@post.id}" }
      it_assigns @post
      it_assigns_flash_cookie :notice => :not_nil
      it_redirects_to { "http://test.host/forums/#{@forum.id}/topics/#{@topic.id}" }
      
      it "destroys the post" do
        @post.should_receive(:destroy)
        act!
      end
    end
    
    describe "with initial post" do
      before :each do
        @post = @topic.comments.first
        @topic.comments.stub!(:find).and_return @post
      end
      act! { request_to :delete, "/forums/#{@forum.id}/topics/#{@topic.id}/posts/#{@post.id}" }
      it_assigns_flash_cookie :error => :not_nil
      it_redirects_to { "http://test.host/forums/#{@forum.id}/topics/#{@topic.id}" }
    end
  end
end

describe "PostsSweeper" do
  include SpecControllerHelper
  include FactoryScenario
  controller_name 'posts'

  before :each do
    Site.delete_all
    factory_scenario :forum_with_topics
    @sweeper = CommentSweeper.instance
  end
  
  it "observes Section, Board, Topic" do
    ActiveRecord::Base.observers.should include(:comment_sweeper)
  end
  
  it "should expire pages that reference a post" do
    @sweeper.should_receive(:expire_cached_pages_by_reference).with(@topic.initial_post.commentable)
    @sweeper.after_save(@topic.initial_post)
  end
end