require File.dirname(__FILE__) + "/../../spec_helper"

describe Admin::ArticlesController do
  include SpecControllerHelper
 
  before :each do
    stub_scenario :section_with_published_article
    set_resource_paths :article, '/admin/sites/1/sections/1/'
    @params = {:article => {:author => 1}}
    @controller.stub! :require_authentication
    @controller.stub!(:has_permission?).and_return true
    @controller.stub!(:current_user).and_return stub_user
    User.stub!(:find).and_return stub_user
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
    # it_guards_permissions :show, :article # deactivated all :show permissions in the backend
 
    describe "when the section is a Section" do
      before :each do @site.sections.stub!(:find).and_return @section end
      it_renders_template 'admin/articles/index'
    end
 
    describe "when the section is a Blog" do
      before :each do @site.sections.stub!(:find).and_return stub_blog end
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
    # it_guards_permissions :show, :article # deactivated all :show permissions in the backend
 
    it "reverts the article when given a :version param" do
      @article.should_receive(:revert_to).any_number_of_times.with "1"
      request_to :get, @member_path, :version => "1"
    end
  end
 
  describe "GET to :new" do
    act! { request_to :get, @new_member_path }
    it_assigns :article
    it_renders_template :new
    it_guards_permissions :create, :article
 
    it "instantiates a new article from section.articles" do
      @section.articles.should_receive(:build).and_return @article
      act!
    end
  end
 
  describe "POST to :create" do
    before :each do
      @section.articles.stub!(:create).and_return @article
      @article.stub!(:state_changes).and_return([:created])
    end
    
    act! { request_to :post, @collection_path, @params }
    it_assigns :article
    it_guards_permissions :create, :article
    
    it "instantiates a new article from section.articles" do
      @section.articles.should_receive(:build).and_return @article
      act!
    end
 
    describe "given valid article params" do
      it_redirects_to { @edit_member_path }
      it_assigns_flash_cookie :notice => :not_nil
      it_triggers_event :article_created
    end
 
    describe "given invalid article params" do
      before :each do 
        @section.articles.stub!(:build).and_return @article
        @article.stub!(:save).and_return false 
      end
      it_renders_template :new
      it_assigns_flash_cookie :error => :not_nil
      it_does_not_trigger_any_event
    end
  end
 
  describe "GET to :edit" do
    act! { request_to :get, @edit_member_path }
    it_assigns :article
    it_renders_template :edit
    it_guards_permissions :update, :article
 
    it "fetches an article from section.articles" do
      @section.articles.should_receive(:find).any_number_of_times.and_return @article
      act!
    end
  end
 
  describe "PUT to :update" do
    before :each do
      @article.stub!(:state_changes).and_return([:updated])
    end
    act! { request_to :put, @member_path, @params }
    it_assigns :article
    it_guards_permissions :update, :article
 
    it "fetches an article from section.articles" do
      @section.articles.should_receive(:find).any_number_of_times.and_return @article
      act!
    end
 
    it "updates the article with the article params" do
      @article.should_receive(:attributes=).and_return true
      act!
    end
 
    describe "given no version param" do
      describe "and given valid article params" do
        before :each do
          @article.stub!(:save).and_return true
          @article.stub!(:save_without_revision).and_return true
        end
        
        it_redirects_to { @edit_member_path }
        it_assigns_flash_cookie :notice => :not_nil
        it_triggers_event :article_updated
         
        it "saves a new revision when given a :save_revision param" do
          @article.should_receive :save
          request_to :put, @member_path, @params.merge(:save_revision => "1")
        end
 
        it "does not save a new revision when given no :save_revision param" do
          @article.should_receive :save_without_revision
          act!
        end
      end
      
      describe "and given invalid article params" do
        before :each do
          @article.stub!(:save_without_revision).and_return false
        end
        it_renders_template :edit
        it_assigns_flash_cookie :error => :not_nil
        it_does_not_trigger_any_event
      end
    end
      
    describe "given a version param" do 
      act! { request_to :put, @member_path, @params.merge({:article => {:version => "1"}}) }
      
      describe "and the article can be rolled back to the given version" do
        before :each do
          @article.stub!(:revert_to!).and_return true
        end
        
        it_triggers_event :article_rolledback
        it_assigns_flash_cookie :notice => :not_nil
        it_redirects_to { @edit_member_path }
      
        it "reverts the article before saving" do
          @article.should_receive(:revert_to!).any_number_of_times.with "1"
          act!
        end
      end
      
      describe "and the article can not be rolled back to the given version" do
        before :each do
          @article.stub!(:revert_to!).and_return false
        end
        
        it_does_not_trigger_any_event
        it_assigns_flash_cookie :error => :not_nil
        it_redirects_to { @edit_member_path }
      end
    end
 
    describe "given invalid article params" do
      before :each do @article.stub!(:save_without_revision).and_return false end
      it_renders_template :edit
      it_assigns_flash_cookie :error => :not_nil
    end
  end
  
  describe "DELETE to :destroy" do
    before :each do
      @article.stub!(:state_changes).and_return([:deleted])
    end
    
    act! { request_to :delete, @member_path }
    it_assigns :article
    it_guards_permissions :destroy, :article
    it_triggers_event :article_deleted
 
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
 
  it "should have update_all and rollback actions specified"
end

describe Admin::ArticlesController, "page_cache" do
 include SpecControllerHelper

 before :each do
   @filter = Admin::ArticlesController.filter_chain.find ArticleSweeper.instance
 end

 it "activates the ArticleSweeper as an around filter" do
   @filter.should be_kind_of(ActionController::Filters::AroundFilter)
 end

 it "configures the ArticleSweeper to observe Comment create, update, rollback and destroy events" do
   @filter.options[:only].should == [:create, :update, :destroy]
 end
end

describe "ArticleSweeper" do
 include SpecControllerHelper
 controller_name 'admin/articles'

 before :each do
   stub_scenario :section_with_published_article
   @sweeper = ArticleSweeper.instance
 end

 it "observes Article" do
   ActiveRecord::Base.observers.should include(:article_sweeper)
 end

 it "should expire pages that reference the article's section when the article is a new record" do
   @article.stub!(:new_record?).and_return true
   @sweeper.should_receive(:expire_cached_pages_by_reference).with(@article.section)
   @sweeper.before_save(@article)
 end

 it "should expire pages that reference an article when the article is not a new record" do
   @article.stub!(:new_record?).and_return false
   @sweeper.should_receive(:expire_cached_pages_by_reference).with(@article)
   @sweeper.before_save(@article)
 end
end
