require File.dirname(__FILE__) + "/../spec_helper"
require File.dirname(__FILE__) + '/../spec_helpers/spec_comment_helper'

describe CommentsController do
  include SpecControllerHelper
  
  before :each do
    scenario :site, :section, :blog, :article, :comment

    @collection_path = '/comments'
    @member_path = '/comments/1'
    @preview_path = '/comments/preview'
    @return_to = '/redirect/here'
    
    @params = { :commentable => {:type => 'Article', :id => 1}, 
                :comment => {:body => 'body!', :author_name => 'name'},
                :return_to => @return_to }
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
      it_renders_template 'show'
      it_assigns_flash_cookie :notice => :not_nil
    end
    
    describe "given invalid comment params" do
      before :each do 
        @comment.stub!(:save).and_return false 
        @comment.stub!(:errors).and_return mock('errors', :full_messages => ["Name can't be blank"])    
      end
      it_redirects_to { @return_to }
      it_assigns_flash_cookie :error => :not_nil
      it_assigns_flash_cookie :comment => :not_nil
    end    
  end
  
  
end