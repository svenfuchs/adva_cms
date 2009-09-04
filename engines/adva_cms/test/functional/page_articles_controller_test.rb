require File.expand_path(File.dirname(__FILE__) + "/../test_helper")

class PageArticlesControllerTest < ActionController::TestCase
  tests ArticlesController
  # with_common :a_page, :an_article
  with_common :rescue_action_in_public
  
  test "is a BaseController" do
    @controller.should be_kind_of(BaseController)
  end
  
  describe 'GET to :index' do
    action { get :index, params_from("/#{@section.permalink}") }
    
    with :a_page, :an_article do
      with "the page is in single_article_mode" do
        before { @section.single_article_mode = true; @section.save! }

        it_assigns :section
        it_assigns :article
        it_renders :template, 'pages/articles/show'
        it_caches_the_page :track => '@article'
      end
      
      with "the page is not in single_article_mode" do
        it_assigns :section, :articles
        it_renders :template, 'pages/articles/index'
        it_caches_the_page :track => '@articles'
        # FIXME displays a list of articles
      end
    end

    with :an_unpublished_section do
      with "the page is in single_article_mode" do
        before do
          @section.single_article_mode = true
          @section.save!
        end
      
        with "an anonymous user" do
          # it_raises ActiveRecord::RecordNotFound
          assert_status 404
        end
      
        with :is_superuser do
          it_assigns :section, :article
          it_renders :template, 'pages/articles/show'
          it_does_not_cache_the_page
        end
      end

      with "the page is not in single_article_mode" do
        before do
          @section.update_attribute(:published_at, nil)
        end
        with "an anonymous user" do
          # it_raises ActiveRecord::RecordNotFound
          assert_status 404
        end

        with :is_superuser do
          it_assigns :section, :articles
          it_renders :template, 'pages/articles/index'
          it_does_not_cache_the_page
        end
      end
    end
  end
  
  # FIXME these tests are tied to a concept that this given section has only one published article
  describe 'GET to :show' do
    action { get :show, params_from("/#{@section.permalink}/articles/#{@section.articles.first.permalink}") }
    
    with :a_page, :an_article do
      with :the_article_is_published do
        it_assigns :section, :article
        it_renders :template, 'pages/articles/show'
        it_caches_the_page :track => '@article'
        
        it "displays the article's body" do
          has_tag 'div[class~=entry]' do
            has_text @article.title
            has_text @article.body
            assert @response.body !~ /read the rest of this entry/i
          end
        end
        
        # FIXME
        # lists the article's categories
        # lists the article's tags

        # FIXME
        # when article has an approved comment: shows the comment
        # when article has an unapproved comment: does not show any comments
        # when article does not have any comments: does not show any comments
        #
        # when article allows commenting: shows comment form 
        # when article does not allow commenting: does not show comment form 
      end

      with :the_article_is_not_published do
        with "an anonymous user" do
          # it_raises ActiveRecord::RecordNotFound
          assert_status 404
        end
        
        with :is_superuser do
          it_assigns :section, :article => :not_nil
          it_renders :template, 'pages/articles/show'
          it_does_not_cache_the_page
        end
      end
      
      with "the article does not exist" do
        before { @article.destroy }
        # it_raises ActiveRecord::RecordNotFound
        assert_status 404
      end
    end

    with :an_unpublished_section do
      with "an anonymous user" do
        # it_raises ActiveRecord::RecordNotFound
          assert_status 404
      end
      
      with :is_superuser do
        it_assigns :section, :article
        it_renders :template, 'pages/articles/show'
        it_does_not_cache_the_page
      end
    end
  end

  describe "GET to :comments atom feed with no article permalink given" do
    action { get :comments, params_from("/a-page/comments.atom") }
  
    with :a_page, :an_article do
      with :the_article_is_published do
        it_assigns :section, :comments
        it_renders :template, 'comments/comments', :format => :atom
        it_caches_the_page
        # FIXME specify comments atom feed
      end
      
      with :the_article_is_not_published do
        # FIXME should raise RecordNotFound
      end
    end
  end
  
  describe "GET to :comments atom feed with an article permalink given" do
    action { get :comments, params_from("/a-page/articles/a-page-article.atom") }
  
    with :a_page, :an_article do
      with :the_article_is_published do
        it_assigns :section, :commentable, :comments
        it_renders :template, 'comments/comments', :format => :atom
        it_caches_the_page
        # FIXME specify comments atom feed
      end
      
      with :the_article_is_not_published do
        # FIXME should raise RecordNotFound
      end
    end
  end
end