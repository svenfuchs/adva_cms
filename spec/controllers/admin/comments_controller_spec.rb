require File.dirname(__FILE__) + "/../../spec_helper"

describe Admin::CommentsController do
  include SpecControllerHelper
  
  before :each do
    scenario :site, :comment, :article
    set_resource_paths :comment, '/admin/sites/1/'
    @controller.stub! :require_authentication
  end
  
  it "should be an Admin::BaseController" do
    controller.should be_kind_of(Admin::BaseController)
  end
  
  describe "routing" do
    with_options :path_prefix => '/admin/sites/1/', :site_id => '1' do |route|
      route.it_maps :get, "comments", :index
      route.it_maps :get, "comments/1", :show, :id => '1'
      # route.it_maps :get, "comments/new", :new
      # route.it_maps :post, "comments", :create
      route.it_maps :get, "comments/1/edit", :edit, :id => '1'
      route.it_maps :put, "comments/1", :update, :id => '1'
      route.it_maps :delete, "comments/1", :destroy, :id => '1'
    end
  end
  
  describe "GET to :index" do
    act! { request_to :get, @collection_path }    
    it_assigns :comments
    it_renders_template :index
  end
   
  # describe "GET to :show" do
  #   act! { request_to :get, @member_path }    
  #   it_assigns :comment
  #   it_renders_template :show
  #   
  #   it "fetches a comment from site.comments" do
  #     @site.comments.should_receive(:find).and_return @comment
  #     act!
  #   end
  # end 
  # 
  # describe "GET to :new" do
  #   act! { request_to :get, @new_member_path }    
  #   it_assigns :comment
  #   it_renders_template :new
  #   
  #   it "instantiates a new comment from site.comments" do
  #     @site.comments.should_receive(:build).and_return @comment
  #     act!
  #   end    
  # end
  # 
  # describe "POST to :create" do
  #   act! { request_to :post, @collection_path }    
  #   it_assigns :comment
  #   
  #   it "instantiates a new comment from site.comments" do
  #     @site.comments.should_receive(:build).and_return @comment
  #     act!
  #   end
  #   
  #   describe "given valid comment params" do
  #     it_redirects_to { @member_path }
  #     it_assigns_flash_cookie :notice => :not_nil
  #   end
  #   
  #   describe "given invalid comment params" do
  #     before :each do @comment.stub!(:save).and_return false end
  #     it_renders_template :new
  #     it_assigns_flash_cookie :error => :not_nil
  #   end    
  # end
   
  describe "GET to :edit" do
    act! { request_to :get, @edit_member_path }    
    it_assigns :comment
    it_renders_template :edit
    
    it "fetches a comment from site.comments" do
      @site.comments.should_receive(:find).and_return @comment
      act!
    end
  end 
  
  describe "PUT to :update" do
    act! { request_to :put, @member_path, :return_to => '/redirect/here' }    
    it_assigns :comment    
    
    it "fetches a comment from site.comments" do
      @site.comments.should_receive(:find).and_return @comment
      act!
    end  
    
    it "updates the comment with the comment params" do
      @comment.should_receive(:update_attributes).and_return true
      act!
    end
    
    describe "given valid comment params" do
      it_redirects_to { '/redirect/here' }
      it_assigns_flash_cookie :notice => :not_nil
    end
    
    describe "given invalid comment params" do
      before :each do @comment.stub!(:update_attributes).and_return false end
      it_renders_template :edit
      it_assigns_flash_cookie :error => :not_nil
    end
  end
  
  describe "DELETE to :destroy" do
    act! { request_to :delete, @member_path, :return_to => '/redirect/here' }    
    it_assigns :comment
    
    it "fetches a comment from site.comments" do
      @site.comments.should_receive(:find).and_return @comment
      act!
    end 
    
    it "should try to destroy the comment" do
      @comment.should_receive :destroy
      act!
    end 
    
    describe "when destroy succeeds" do
      it_redirects_to { '/redirect/here' }
      it_assigns_flash_cookie :notice => :not_nil
    end
    
    describe "when destroy fails" do
      before :each do @comment.stub!(:destroy).and_return false end
      it_redirects_to { '/redirect/here' }
      it_assigns_flash_cookie :error => :not_nil
    end
  end
end