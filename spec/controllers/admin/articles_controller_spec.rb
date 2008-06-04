require File.dirname(__FILE__) + "/../../spec_helper"

describe Admin::ArticlesController do
  include SpecControllerHelper
  
  before :each do
    scenario :site, :section, :blog, :category, :article
    set_resource_paths :article, '/admin/sites/1/sections/1/'
    @controller.stub! :require_authentication
    @controller.stub! :guard_permission
  end
  
  it "should be an Admin::BaseController" do
    controller.should be_kind_of(Admin::BaseController)
  end
  
  describe "routing" do
    with_options :path_prefix => '/admin/sites/1/sections/1/', :site_id => "1", :section_id => "1" do |route|
      route.it_maps :get, "articles", :index
      route.it_maps :get, "articles/1", :show, :id => '1'
      route.it_maps :get, "articles/new", :new
      route.it_maps :post, "articles", :create
      route.it_maps :get, "articles/1/edit", :edit, :id => '1'
      route.it_maps :put, "articles/1", :update, :id => '1'
      route.it_maps :delete, "articles/1", :destroy, :id => '1'
    end
  end
  
  describe "GET to :index" do
    act! { request_to :get, @collection_path }    
    it_assigns :articles
    
    describe "when the section is a Section" do
      before :each do @site.sections.stub!(:find).and_return @section end
      it_renders_template 'admin/articles/index'
    end
    
    describe "when the section is a Blog" do
      before :each do @site.sections.stub!(:find).and_return @blog end
      it_renders_template 'admin/blog/index'
    end
    
    describe "filters" do
      it "should fetch articles belonging to a category when :filter == category" do
        options = hash_including(:conditions => "category_assignments.category_id = 1")
        @section.articles.should_receive(:paginate).with options
        request_to :get, @collection_path, :filter => 'category', :category => '1'
      end
    
      it "should fetch articles by checking the title when :filter == title" do
        options = hash_including(:conditions => "LOWER(contents.title) LIKE '%foo%'")
        @section.articles.should_receive(:paginate).with options
        request_to :get, @collection_path, :filter => 'title', :query => 'foo'
      end
    
      it "should fetch articles by checking the excerpt and body when :filter == body" do
        options = hash_including(:conditions => "LOWER(contents.excerpt) LIKE '%foo%' OR LOWER(contents.body) LIKE '%foo%'")
        @section.articles.should_receive(:paginate).with options
        request_to :get, @collection_path, :filter => 'body', :query => 'foo'
      end
      
      it "should fetch articles by checking the tags when :filter == tags" do
        options = hash_including(:conditions => "tags.name IN ('foo','bar')")
        @section.articles.should_receive(:paginate).with options
        request_to :get, @collection_path, :filter => 'tags', :query => 'foo bar'
      end    
      
      it "should fetch articles by checking published_at when :filter == draft" do
        options = hash_including(:conditions => "published_at is null")
        @section.articles.should_receive(:paginate).with options
        request_to :get, @collection_path, :filter => 'draft'
      end    
    end    
  end
  
  describe "GET to :show" do    
    act! { request_to :get, @member_path }
    it_assigns :article
  
    it "reverts the article when given a :version param" do
      @article.should_receive(:revert_to).any_number_of_times.with "1"
      request_to :get, @member_path, :version => "1"
    end        
  end  
  
  describe "GET to :new" do
    act! { request_to :get, @new_member_path }    
    it_assigns :article
    it_renders_template :new
    
    it "instantiates a new article from section.articles" do
      @section.articles.should_receive(:build).and_return @article
      act!
    end    
  end
  
  describe "POST to :create" do
    act! { request_to :post, @collection_path }    
    it_assigns :article
    
    it "instantiates a new article from section.articles" do
      @section.articles.should_receive(:build).and_return @article
      act!
    end
    
    describe "given valid article params" do
      it_redirects_to { @edit_member_path }
      it_assigns_flash_cookie :notice => :not_nil
    end
    
    describe "given invalid article params" do
      before :each do @article.stub!(:save).and_return false end
      it_renders_template :new
      it_assigns_flash_cookie :error => :not_nil
    end    
  end
   
  describe "GET to :edit" do
    act! { request_to :get, @edit_member_path }    
    it_assigns :article
    it_renders_template :edit
    
    it "fetches an article from section.articles" do
      @section.articles.should_receive(:find).any_number_of_times.and_return @article
      act!
    end
  end 
  
  describe "PUT to :update" do
    act! { request_to :put, @member_path }    
    it_assigns :article    
    
    it "fetches an article from section.articles" do
      @section.articles.should_receive(:find).any_number_of_times.and_return @article
      act!
    end  
    
    it "updates the article with the article params" do
      @article.should_receive(:attributes=).and_return true
      act!
    end
    
    describe "given valid article params" do
      it_redirects_to { @edit_member_path }
      it_assigns_flash_cookie :notice => :not_nil
    end
    
    describe "given invalid article params" do
      before :each do @article.stub!(:save_without_revision).and_return false end
      it_renders_template :edit
      it_assigns_flash_cookie :error => :not_nil
    end
    
    it "saves a new revision when given a :save_revision param" do
      @article.should_receive :save
      request_to :put, @member_path, :save_revision => "1"
    end
    
    it "does not save a new revision when given no :save_revision param" do
      @article.should_receive :save_without_revision
      act!
    end
    
    it "reverts the article before saving when given a version param" do
      @article.should_receive(:revert_to).any_number_of_times.with "1"
      request_to :put, @member_path, :version => "1"
    end    
  end
  
  describe "DELETE to :destroy" do
    act! { request_to :delete, @member_path }    
    it_assigns :article
    
    it "fetches an article from section.articles" do
      @section.articles.should_receive(:find).any_number_of_times.and_return @article
      act!
    end 
    
    it "should try to destroy the article" do
      @article.should_receive :destroy
      act!
    end 
    
    describe "when destroy succeeds" do
      it_redirects_to { @collection_path }
      it_assigns_flash_cookie :notice => :not_nil
    end
    
    describe "when destroy fails" do
      before :each do @article.stub!(:destroy).and_return false end
      it_renders_template :edit
      it_assigns_flash_cookie :error => :not_nil
    end
  end
end