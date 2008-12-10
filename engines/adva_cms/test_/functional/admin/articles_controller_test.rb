require File.dirname(__FILE__) + "/../../test_helper"

class AdminArticlesControllerTest < ActionController::TestCase
  tests Admin::ArticlesController
 
  def setup
    stub(@controller).guard_permission
    stub(@controller).require_authentication
    stub(@controller).current_user{ User.make }
  end

  # it "should be an Admin::BaseController" do
  #   controller.should be_kind_of(Admin::BaseController)
  # end
 
  describe "routing" do
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
  
  describe "GET to :index" do
    before do
      stub(@controller).guard_permission
      stub(@controller).require_authentication
      stub(@controller).current_user{ User.make }
    end
    
    action { get :index, :site_id => @site.id, :section_id => @section.id }
    
    with :an_empty_section do
      it_assigns :articles
      it_renders :template, 'admin/articles/index'
    end
   
    with :an_empty_blog do
      it_assigns :articles
      it_renders :template, 'admin/blog/index'
    end
   
    describe "filter_options", :with => :an_empty_section do
      before do
        @controller.instance_variable_set :@section, @section
      end
      
      it "fetches articles belonging to a category when :filter == category" do
        @controller.params = {:filter => 'category', :category => '1'}
        filter_options.should == {:conditions => "category_assignments.category_id = 1"}
      end
     
      it "fetches articles by checking the title when :filter == title" do
        @controller.params = {:filter => 'title', :query => 'foo'}
        filter_options.should == {:conditions => "LOWER(contents.title) LIKE '%foo%'"}
      end
     
      it "fetches articles by checking the excerpt and body when :filter == body" do
        @controller.params = {:filter => 'body', :query => 'foo'}
        filter_options.should == {:conditions => "LOWER(contents.excerpt) LIKE '%foo%' OR LOWER(contents.body) LIKE '%foo%'"}
      end
     
      it "fetches articles by checking the tags when :filter == tags" do
        @controller.params = {:filter => 'tags', :query => 'foo bar'}
        filter_options.should == {:conditions => "tags.name IN ('foo','bar')"}
      end
     
      it "fetches articles by checking published_at when :filter == draft" do
        @controller.params = {:filter => 'draft'}
        filter_options.should == {:conditions => "published_at is null"}
      end 
    end
  end
    
  def filter_options
    @controller.send(:filter_options).slice(:conditions)
  end
   
  describe "GET to :show" do
    action { get :show, @params }

    with :published_blog_article do
      before { @params = {:site_id => @site.id, :section_id => @section.id, :id => @article.id} }
      
      it "previews the article in the frontend layout" do
        it_assigns :article => :not_nil
        it_renders :template, 'blog/show'
      end
      
      with "given a :version param" do
        before do
          @params.update :version => 1
          @article.update_attributes :title => 'new title'
        end
        action { get :show, :site_id => @site.id, :section_id => @section.id, :id => @article.id }

        it "reverts the article to the given version" do
          assigns(:article).version.should == 1
        end
      end
    end
  
    with :published_section_article do
      before { @params = {:site_id => @site.id, :section_id => @section.id, :id => @article.id} }
      
      it "previews the article in the frontend layout" do
        it_assigns :article => :not_nil
        it_renders :template, 'sections/show'
      end
    end
  end
  
  # test "GET to :new" do
  #   setup_site_with_an_empty_blog
  #   get :new, :site_id => @site.id, :section_id => @section.id
  #   
  #   it_assigns :article
  #   it_renders_template :new
  #   # it_guards_permissions :create, :article
  #  
  #   assigns(:article).section.should == @section
  # end
 
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