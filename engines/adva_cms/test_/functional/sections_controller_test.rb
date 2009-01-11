require File.expand_path(File.dirname(__FILE__) + "/../test_helper")

class SectionsControllerTest < ActionController::TestCase
  with_common :a_section, :an_article
  
  describe "routing" do
    # FIXME test paged routes
    ['/a-section' ].each do |path_prefix|
      # FIXME how to remove the assumption Section.first from here?
      with_options :section_id => Section.first.id.to_s, :path_prefix => path_prefix do |r|
        r.it_maps :get, '/',                         :action => 'show'
        r.it_maps :get, '/articles/an-article',      :action => 'show', :permalink => 'an-article'
        r.it_maps :get, '/articles/an-article.atom', :action => 'comments', :permalink => 'an-article', :format => 'atom'
      end

      # this does only work with a path prefix (as in /a-section/comments.atom) because the root_section filter
      # does not kick in for the "comments" segment ... not sure if this can be changed because there's also
      # a regular comments resource
      # FIXME how to remove the assumption Section.first from here?
      it_maps :get, '/a-section/comments.atom', :action => 'comments', :section_id => Section.first.id.to_s, :format => 'atom'
    end
  end

  test "is a BaseController" do
    BaseController.should === @controller # FIXME matchy doesn't have a be_kind_of matcher
  end
  
  describe "GET to :show with no article permalink given" do
    action { get :show, params_from("/a-section") }
    
    with :the_article_is_published do
      it_assigns :section, :article
      it_renders :template, :show
      it_caches_the_page :track => '@article'
      
      it "assigns the section's primary article" do
        assigns(:article).should == @section.articles.primary
      end
    end
  end
    
  describe "GET to :show with an article permalink given" do
    action { get :show, params_from("/a-section/articles/a-section-article") }
    
    with :the_article_is_published do
      it_assigns :section, :article
      it_renders :template, :show
      it_caches_the_page :track => '@article'

      it "assigns the article referenced by the permalink" do
        assigns(:article).permalink.should == @article.permalink
      end
    end
    
    with :the_article_is_not_published do
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

  describe "GET to :comments with no article permalink given" do
    action { get :comments, params_from("/a-section/comments.atom") }

    with :the_article_is_published do
      it_assigns :section, :comments
      it_renders :template, 'comments/comments', :format => :atom
    end
  end

  describe "GET to :comments with an article permalink given" do
    action { get :comments, params_from("/a-section/articles/a-section-article.atom") }

    with :the_article_is_published do
      it_assigns :section, :article, :comments
      it_renders :template, 'comments/comments', :format => :atom
    end
  end
end