require File.dirname(__FILE__) + "/../../test_helper"
  
# TODO
# try stubbing #perform_action for it_guards_permissions
# specify update_all action
# somehow publish passed/failed expectations from RR to test/unit result?
# make --with=access_control,caching options accessible from the console (Test::Unit runner)

# With.aspects << :access_control

class AdminArticlesControllerTest < ActionController::TestCase
  tests Admin::ArticlesController

  def setup
    super
    login_as_superuser!
  end
  
  def default_params
    { :site_id => @site.id, :section_id => @section.id }
  end

  def filter_options
    @controller.send(:filter_options).slice(:conditions)
  end
    
  def admin_view_directory(section)
    @section.is_a?(Blog) ? 'blog' : 'articles'
  end
  
  def view_directory(section)
    @section.is_a?(Blog) ? 'blog' : 'sections'
  end
   
  test "is an Admin::BaseController" do
    Admin::BaseController.should === @controller # FIXME matchy doesn't have a be_kind_of matcher
  end
   
  describe "routing" do
    with_options :path_prefix => '/admin/sites/1/sections/1/', :site_id => "1", :section_id => "1" do |r|
      r.it_maps :get,    "articles",        :action => 'index'
      r.it_maps :get,    "articles/1",      :action => 'show',    :id => '1'
      r.it_maps :get,    "articles/new",    :action => 'new'
      r.it_maps :post,   "articles",        :action => 'create'
      r.it_maps :get,    "articles/1/edit", :action => 'edit',    :id => '1'
      r.it_maps :put,    "articles/1",      :action => 'update',  :id => '1'
      r.it_maps :delete, "articles/1",      :action => 'destroy', :id => '1'
    end
  end
  
  describe "GET to :index" do
    action { get :index, default_params }
    
    with :an_empty_section, :an_empty_blog do
      it_guards_permissions :show, :article
      
      with :access_granted do
        it_assigns :articles
        it_renders :template, lambda { "admin/#{admin_view_directory(@section)}/index" }
      end
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

  describe "GET to :show" do
    action { get :show, @params }
  
    with :published_blog_article, :published_section_article do
      before { @params = default_params.merge(:id => @article.id) }
      
      it_guards_permissions :show, :article
    
      with :access_granted do
        it "previews the article in the frontend layout" do
          it_assigns :article => :not_nil
          it_renders :template, lambda { "#{view_directory(@section)}/show" }
        end
    
        with "given a :version param" do
          before do
            @params.merge! :version => 1
            @article.update_attributes :title => 'new title'
          end
      
          it "reverts the article to the given version" do
            assigns(:article).version.should == 1
          end
        end
      end
    end
  end
  
  describe "GET to :new" do
    action { get :new, default_params }
    
    with :an_empty_section, :an_empty_blog do
      it_guards_permissions :create, :article
      with :access_granted do
        it_assigns :site, :section, :article
        it_renders_template :new
      end
    end
  end
  
  describe "POST to :create" do
    action do 
      Article.with_observers :article_sweeper do
        post :create, default_params.merge(@params)
      end
    end
    
    with :an_empty_section, :an_empty_blog do
      with :valid_article_params do
        it_guards_permissions :create, :article
  
        with :access_granted do
          it_assigns :site, :section, :article
          it_changes 'Article.count' => 1
          it_triggers_event :article_created
          it_assigns_flash_cookie :notice => :not_nil
          it_redirects_to { edit_admin_article_path(@site.id, @section.id, assigns(:article).id) }
          it_sweeps_page_cache :by_reference => :section
              
          it "associates the new Article to the current site" do
            assigns(:article).reload.site.should == @site
          end
              
          it "associates the new Article to the current section" do
            assigns(:article).reload.section.should == @section
          end
        end
      end
  
      with :invalid_article_params do
        with :access_granted do
          it_assigns :site, :section, :article
          it_does_not_change 'Article.count'
          it_does_not_trigger_any_event
          it_renders_template :new
          it_assigns_flash_cookie :error => :not_nil
          it_does_not_sweep_page_cache
        end
      end
    end
  end
   
  describe "GET to :edit" do
    action { get :edit, default_params.merge(:id => @article.id) }
  
    with :an_empty_section, :an_empty_blog do
      with :a_published_article do
        it_guards_permissions :update, :article
        
        with :access_granted do
          it_assigns :site, :section, :article
          it_renders_template :edit
        end
      end
    end
  end
   
  describe "PUT to :update" do
    action do 
      Article.with_observers :article_sweeper do
        params = default_params.merge(@params).merge(:id => @article.id)
        params[:article][:title] = "#{@article.title} was changed" unless params[:article][:title].blank?
        put :update, params
      end
    end
  
    with :an_empty_section, :an_empty_blog do
      with :a_published_article do
        with "no version param" do
          with :valid_article_params do
            it_guards_permissions :update, :article
            
            with :access_granted do
              it_assigns :site, :section, :article
              it_updates :article
              it_redirects_to { edit_admin_article_path(@site, @section, @article) }
              it_assigns_flash_cookie :notice => :not_nil
              it_triggers_event :article_updated
              it_sweeps_page_cache :by_reference => :article
  
              with(:save_revision_param)    { it_versions :article }
              with(:no_save_revision_param) { it_does_not_version :article }
            end
          end
          
          with :invalid_article_params do
            with :access_granted do
              it_assigns :site, :section, :article
              it_renders_template :edit
              it_assigns_flash_cookie :error => :not_nil
              it_does_not_trigger_any_event
              it_does_not_sweep_page_cache
            end
          end
        end
        
        with "version param set to 1" do
          before { @params = default_params.merge(:article => {:version => "1"}) }
          
          with "the article being versioned (succeeds)" do
            before { @article.update_attributes(:title => "#{@article.title} was changed") }
          
            it_rollsback :article, :to => 1
            it_triggers_event :article_rolledback
            it_assigns_flash_cookie :notice => :not_nil
            it_redirects_to { edit_admin_article_path(@site, @section, @article) }
            it_sweeps_page_cache :by_reference => :article
          end
          
          with "the article not being versioned (fails)" do
            it_does_not_rollback :article
            it_does_not_trigger_any_event
            it_assigns_flash_cookie :error => :not_nil
            it_redirects_to { edit_admin_article_path(@site, @section, @article) }
            it_does_not_sweep_page_cache
          end
        end
      end
    end
  end
  
  describe "DELETE to :destroy" do
    with :an_empty_section, :an_empty_blog do
      with :a_published_article do
        action do 
          Article.with_observers :article_sweeper do
            delete :destroy, default_params.merge(:id => @article.id)
          end
        end
        
        it_guards_permissions :destroy, :article
        
        with :access_granted do
          it_assigns :site, :section, :article
          it_destroys :article
          it_triggers_event :article_deleted
          it_sweeps_page_cache :by_reference => :article
          # TODO redirect? flash?
        end
      end
    end
  end
end