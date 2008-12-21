require File.expand_path(File.dirname(__FILE__) + "/../test_helper")

class SectionsControllerTest < ActionController::TestCase
  tests SectionsController
  
  with_common :a_section, :an_article
  
  test "is an BaseController" do
    BaseController.should === @controller # FIXME matchy doesn't have a be_kind_of matcher
  end
  
  describe "GET to :show with no article permalink given" do
    action { get :show, params_from("/sections/#{@section.id}") }
    
    with :the_article_is_published do
      it_assigns :section, :article
      it_renders :template, :show
      it_caches_the_page
      
      it "assigns the section's primary article" do
        assigns(:article).should == @section.articles.primary
      end
    end
  end
    
  describe "GET to :show with an article permalink given" do
    action { get :show, params_from("/sections/1/articles/#{@article.permalink}") }
    
    with :the_article_is_published do
      it_assigns :section, :article
      it_renders :template, :show
      it_caches_the_page
      
      it "assigns the article referenced by the permalink" do
        assigns(:article).permalink.should == @article.permalink
      end
    end
    
    with "the article is not published" do
      with :is_superuser do
        it_assigns :section, :article
        it_renders_template :show
        it_does_not_cache_the_page
      end
      
      with "the user may not update the article" do
        it_redirects_to { login_url(:return_to => @request.url) }
      end
    end
  end
end

# describe SectionsController, 'feeds' do
#   include SpecControllerHelper
# 
#   before :each do
#     stub_scenario :section_with_published_article
#   end
# 
#   comments_paths = %w( /sections/1/comments.atom
#                        /sections/1/articles/an-article.atom)
# 
#   comments_paths.each do |path|
#     describe "GET to #{path}" do
#       act! { request_to :get, path }
#       it_renders_template 'comments/comments', :format => :atom
#       it_gets_page_cached
#     end
#   end
# end
# 
# describe SectionsController, "page_caching" do
#   include SpecControllerHelper
# 
#   it "page_caches the show action" do
#     cached_page_filter_for(:show).should_not be_nil
#   end
# 
#   it "tracks read access on @article for show action page caching" do
#     SectionsController.track_options[:show].should include('@article')
#   end
# 
#   it "page_caches the comments action" do
#     cached_page_filter_for(:comments).should_not be_nil
#   end
# 
#   it "tracks read access on @commentable for comments action page caching" do
#     SectionsController.track_options[:comments].should include('@commentable')
#   end
# end
