require File.dirname(__FILE__) + "/../spec_helper"
require File.dirname(__FILE__) + '/../spec_helpers/spec_comment_helper'

describe CommentsController do
  include SpecControllerHelper
  
  before :each do
    scenario :blog_with_published_article, :blog_comments
    
    controller.class.send :include, ContentHelper

    @collection_path = '/comments'
    @member_path = '/comments/1'
    @preview_path = '/comments/preview'
    @return_to = '/redirect/here'
    
    @params = { :comment => {:body => 'body!', :commentable_type => 'Article', :commentable_id => 1},
                :anonymous => {:name => 'anonymous', :email => 'anonymous@email.org'} }
  end
  
  it "should be a BaseController" do
    controller.should be_kind_of(BaseController)
  end

  describe "GET to :show" do
    act! { request_to :get, @member_path }    
    it_assigns :section, :comment, :commentable
    it_renders_template :show
  end
  
  describe "POST to preview" do
    before :each do
      @comment.stub! :process_filters
    end
    
    act! { request_to :post, @preview_path, @params }    
    it_assigns :comment
    it_renders_template 'preview'
  end
              
  describe "POST to :create" do
    act! { request_to :post, @collection_path, @params }    
    it_assigns :commentable, lambda { @article }
    
    it "instantiates a new comment from commentable.comments" do
      @article.comments.should_receive(:build).and_return @comment
      act!
    end
    
    it "tries to save the comment" do
      @comment.should_receive(:save).and_return true
      act!
    end
    
    describe "given valid comment params" do
      it_redirects_to { @member_path }
      it_assigns_flash_cookie :notice => :not_nil
      
      it "checks the comment's spaminess" do
        url = "http://test.host/sections/1/articles/an-article"
        @comment.should_receive(:check_approval).with(url, :authenticated => false)
        act!
      end
    end
    
    describe "given invalid comment params" do
      before :each do 
        @comment.stub!(:save).and_return false 
        @comment.stub!(:errors).and_return mock('errors', :full_messages => ["Name can't be blank"])    
      end
      it_renders_template :show
      it_assigns_flash_cookie :error => :not_nil
    end    
  end
              
  describe "PUT to :update" do
    act! { request_to :put, @member_path, @params }    
    
    it "finds the comment" do
      Comment.should_receive(:find).and_return @comment
      act!
    end
    
    it "tries to update the comment attributes" do
      @comment.should_receive(:update_attributes).and_return true
      act!
    end
    
    describe "given valid comment params" do
      it_redirects_to { @member_path }
      it_assigns_flash_cookie :notice => :not_nil
    end
    
    describe "given invalid comment params" do
      before :each do 
        @comment.stub!(:update_attributes).and_return false 
        @comment.stub!(:errors).and_return mock('errors', :full_messages => ["Name can't be blank"])    
      end
      it_renders_template :show
      it_assigns_flash_cookie :error => :not_nil
    end    
  end
end

describe "Comment page_caching" do
  include SpecControllerHelper
  
  describe CommentsController do    
    before :each do
      @sweeper = CommentsController.filter_chain.find CommentSweeper.instance
    end
    
    it "activates the CommentSweeper as an around filter" do
      @sweeper.should be_kind_of(ActionController::Filters::AroundFilter)
    end
      
    it "configures the CommentSweeper to observe Comment create, update and destroy events" do
      @sweeper.options[:only].should == [:create, :update, :destroy]
    end
  end
  
  describe "CommentSweeper" do
    controller_name 'comments'
  
    before :each do
      scenario :blog_with_published_article, :blog_comments
      @sweeper = CommentSweeper.instance
      @comment.stub!(:commentable).and_return @section
    end
    
    it "observes Comment" do 
      ActiveRecord::Base.observers.should include(:comment_sweeper)
    end
    
    it "expires pages that reference a comment's commentable when the comment was saved" do
      @sweeper.should_receive(:expire_cached_pages_by_reference).with(@section)
      @sweeper.after_save(@comment)
    end
  end
end