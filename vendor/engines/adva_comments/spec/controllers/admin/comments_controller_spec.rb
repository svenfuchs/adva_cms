require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::CommentsController do
  include SpecControllerHelper

  before :each do
    scenario :blog_with_published_article, :blog_comments
    set_resource_paths :comment, '/admin/sites/1/'
    @controller.stub! :require_authentication
    @controller.stub!(:has_permission?).and_return true
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
  
  describe "filters" do
    before :each do
      @section = stub_blog
      @section.comments.stub!(:paginate).and_return @comments
      @parameters = {:section_id => @section.id}
      @controller.stub!(:set_content)
      @controller.stub!(:set_contents)
      @default_options = { :order=>"created_at DESC", :per_page=>nil, :page=> @site.id }
      
      @site.sections.should_receive(:find).with("#{@section.id}").and_return(@section)
    end
    
    it "should have :order, :per_page and :page parameters set as a default options" do
      query_params = { :filter => 'all' }
      
      options = hash_including(:order=>"created_at DESC", :per_page=>nil, :page=> @site.id)
      @section.comments.should_receive(:paginate).with(options).and_return(@comments)
      request_to :get, @collection_path, @parameters.merge(query_params)
    end
    
    it "should fetch approved comments when :filter == state and :state == approved" do
      query_params = { :filter => 'state', :state => 'approved' }
      
      options = hash_including(:conditions => "approved = '1'")
      @section.comments.should_receive(:paginate).with(options).and_return(@comments)
      request_to :get, @collection_path, @parameters.merge(query_params)
    end

    it "should fetch unapproved comments when :filter == state and :state == unapproved" do
      query_params = { :filter => 'state', :state => 'unapproved' }
  
      options = hash_including(:conditions => "unapproved = '0'")
      @section.comments.should_receive(:paginate).with(options).and_return(@comments)
      request_to :get, @collection_path, @parameters.merge(query_params)
    end

    it "should fetch comments by checking the body when :filter == body" do
      query_params = { :filter => 'body', :query => 'foo' }
  
      options = hash_including(:conditions => "LOWER(body) LIKE '%foo%'")
      @section.comments.should_receive(:paginate).with(options).and_return(@comments)
      request_to :get, @collection_path, @parameters.merge(query_params)
    end

    it "should fetch comments by checking the author name when :filter == author_name" do
      query_params = { :filter => 'author_name', :query => 'foo' }
  
      options = hash_including(:conditions => "LOWER(author_name) LIKE '%foo%'")
      @section.comments.should_receive(:paginate).with(options).and_return(@comments)
      request_to :get, @collection_path, @parameters.merge(query_params)
    end

    it "should fetch comments by checking author email when :filter == author_email" do
      query_params = { :filter => 'author_email', :query => 'foo@bar.baz' }
  
      options = hash_including(:conditions => "LOWER(author_email) LIKE '%foo@bar.baz%'")
      @section.comments.should_receive(:paginate).with(options).and_return(@comments)
      request_to :get, @collection_path, @parameters.merge(query_params)
    end

    it "should fetch comments by checking author website when :filter == author_website" do
      query_params = { :filter => 'author_website', :query => 'homepage' }
  
      options = hash_including(:conditions => "LOWER(author_homepage) LIKE '%homepage%'")
      @section.comments.should_receive(:paginate).with(options).and_return(@comments)
      request_to :get, @collection_path, @parameters.merge(query_params)
    end
  end

  describe "GET to :index" do
    act! { request_to :get, @collection_path }
    it_assigns :comments
    it_renders_template :index
    # it_guards_permissions :show, :comment # deactivated all :show permissions in the backend
  end

  # describe "GET to :show" do
  #   act! { request_to :get, @member_path }
  #   it_assigns :comment
  #   it_renders_template :show
  #   it_guards_permissions :show, :comment
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
  #   it_guards_permissions :create, :comment
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
  #   it_guards_permissions :create, :comment
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
    it_guards_permissions :update, :comment

    it "fetches a comment from site.comments" do
      @site.comments.should_receive(:find).and_return @comment
      act!
    end
  end

  describe "PUT to :update" do
    act! { request_to :put, @member_path, :return_to => '/redirect/here' }
    it_assigns :comment
    it_guards_permissions :update, :comment

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
    it_guards_permissions :destroy, :comment

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