require File.dirname(__FILE__) + "/../../test_helper"

class AdminArticlesControllerTest < ActionController::TestCase
  tests Admin::ArticlesController
  # include SpecControllerHelper

  def setup_empty_site
    @site = Site.make
  end
  
  def setup_site_with_an_empty_section
    setup_empty_site
    @section = Section.make :site => @site
  end
  
  def setup_site_with_an_empty_blog
    setup_empty_site
    @section = Blog.make :site => @site
  end
  
  def setup_site_with_a_section_with_an_article
    setup_site_with_an_empty_section
    @article = Article.make :site => @site, :section => @section
  end
  
  def setup_site_with_a_blog_with_an_article
    setup_site_with_an_empty_blog
    @article = Article.make :site => @site, :section => @section
  end
 
  before :each do
    stub(@controller).guard_permission
    stub(@controller).require_authentication
    stub(@controller).current_user{ User.make }
  end

  # it "should be an Admin::BaseController" do
  #   controller.should be_kind_of(Admin::BaseController)
  # end
 
  test "routes" do
    with_options :controller => 'admin/articles', :site_id => "1", :section_id => "1" do |r|
      r.it_maps :get,    "/admin/sites/1/sections/1/articles",        :action => 'index'
      r.it_maps :get,    "/admin/sites/1/sections/1/articles/1",      :action => 'show',    :id => '1'
      r.it_maps :get,    "/admin/sites/1/sections/1/articles/new",    :action => 'new'
      r.it_maps :post,   "/admin/sites/1/sections/1/articles",        :action => 'create'
      r.it_maps :get,    "/admin/sites/1/sections/1/articles/1/edit", :action => 'edit',    :id => '1'
      r.it_maps :put,    "/admin/sites/1/sections/1/articles/1",      :action => 'update',  :id => '1'
      r.it_maps :delete, "/admin/sites/1/sections/1/articles/1",      :action => 'destroy', :id => '1'
    end
  end
  
  context "GET to :index" do
    test "when the section is an empty Section" do
      setup_site_with_an_empty_section
      get :index, :site_id => @site.id, :section_id => @section.id
      
      it_assigns :articles
      it_renders :template, 'admin/articles/index'
    end
 
    test "when the section is an empty Blog" do
      setup_site_with_an_empty_blog
      get :index, :site_id => @site.id, :section_id => @section.id
      
      it_assigns :articles
      it_renders :template, 'admin/blog/index'
    end

    context "filter_options" do
      before :all do
        @section = Section.make
        @controller.instance_variable_set :@section, @section
      end

      test "fetches articles belonging to a category when :filter == category" do
        @controller.params = {:filter => 'category', :category => '1'}
        expected = {:conditions => "category_assignments.category_id = 1"}
        @controller.send(:filter_options).slice(:conditions).should == expected
      end
     
      test "fetches articles by checking the title when :filter == title" do
        @controller.params = {:filter => 'title', :query => 'foo'}
        expected = {:conditions => "LOWER(contents.title) LIKE '%foo%'"}
        @controller.send(:filter_options).slice(:conditions).should == expected
      end
     
      test "fetches articles by checking the excerpt and body when :filter == body" do
        @controller.params = {:filter => 'body', :query => 'foo'}
        expected = {:conditions => "LOWER(contents.excerpt) LIKE '%foo%' OR LOWER(contents.body) LIKE '%foo%'"}
        @controller.send(:filter_options).slice(:conditions).should == expected
      end
     
      test "fetches articles by checking the tags when :filter == tags" do
        @controller.params = {:filter => 'tags', :query => 'foo bar'}
        expected = {:conditions => "tags.name IN ('foo','bar')"}
        @controller.send(:filter_options).slice(:conditions).should == expected
      end
     
      test "fetches articles by checking published_at when :filter == draft" do
        @controller.params = {:filter => 'draft'}
        expected = {:conditions => "published_at is null"}
        @controller.send(:filter_options).slice(:conditions).should == expected
      end 
    end
  end
 
  context "GET to :show" do
    context "when the section is a Blog" do
      test "previews the article in the frontend layout" do
        setup_site_with_a_blog_with_an_article
        get :show, :site_id => @site.id, :section_id => @section.id, :id => @article.id
      
        it_assigns :article
        it_renders :template, 'blog/show'
      end
      
      test "reverts the article when given a :version param" do
        setup_site_with_a_blog_with_an_article
        @article.update_attributes :title => 'new title'
        
        get :show, :site_id => @site.id, :section_id => @section.id, :id => @article.id, :version => "1"
        assigns(:article).version.should == 1
      end
    end

    context "when the section is a Section" do
      test "previews the article in the frontend layout" do
        setup_site_with_a_section_with_an_article
        get :show, :site_id => @site.id, :section_id => @section.id, :id => @article.id
        it_renders :template, 'sections/show'
      end
    end
  end
  
  test "GET to :new" do
    setup_site_with_an_empty_blog
    get :new, :site_id => @site.id, :section_id => @section.id
    
    it_assigns :article
    it_renders_template :new
    # it_guards_permissions :create, :article
   
    assigns(:article).section.should == @section
  end
 
  # context "POST to :create" do
  #   before :each do
  #     @section.articles.stub!(:create).and_return @article
  #     @article.stub!(:state_changes).and_return([:created])
  #   end
  #   
  #   act! { request_to :post, @collection_path, @params }
  #   it_assigns :article
  #   it_guards_permissions :create, :article
  #   
  #   test "instantiates a new article from section.articles" do
  #     @section.articles.should_receive(:build).and_return @article
  #     act!
  #   end
  #  
  #   test "given valid article params" do
  #     it_redirects_to { @edit_member_path }
  #     it_assigns_flash_cookie :notice => :not_nil
  #     it_triggers_event :article_created
  #   end
  #  
  #   test "given invalid article params" do
  #     before :each do 
  #       @section.articles.stub!(:build).and_return @article
  #       @article.stub!(:save).and_return false 
  #     end
  #     it_renders_template :new
  #     it_assigns_flash_cookie :error => :not_nil
  #     it_does_not_trigger_any_event
  #   end
  # end
end