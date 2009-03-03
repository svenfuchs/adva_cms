require File.expand_path(File.dirname(__FILE__) + "/../test_helper")

class SectionArticlesControllerTest < ActionController::TestCase
  # with_common :a_section, :an_article
  
  test "is a BaseController" do
    @controller.should be_kind_of(BaseController)
  end
  
  describe 'GET to :index' do
    action { get :index, params_from('/a-section') }
    
    with :a_section do
      with "the section has some articles" do
        it_assigns :section, :articles
        it_renders :template, 'sections/articles/index'
        it_caches_the_page :track => '@articles'
        # FIXME displays a list of articles
      end

      with "the section does not have any articles" do
        before { @section.articles.clear }
        it_assigns :section
        it_does_not_assign :article
        it_renders :template, 'sections/articles/show'
        it_caches_the_page :track => '@article'
      end
    end
  end
  
  describe 'GET to :show' do
    action { get :show, params_from('/a-section/articles/a-section-article') }
    
    with :a_section, :an_article do
      with :the_article_is_published do
        it_assigns :section, :article
        it_renders :template, 'sections/articles/show'
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
          it_raises ActiveRecord::RecordNotFound
        end
        
        with :is_superuser do
          it_assigns :section, :article
          it_renders :template, 'sections/articles/show'
          it_does_not_cache_the_page
        end
      end

      with "the article does not exist" do
        before { @article.destroy }
        it_raises ActiveRecord::RecordNotFound
      end
    end
  end

  describe "GET to :comments atom feed with no article permalink given" do
    action { get :comments, params_from("/a-section/comments.atom") }
  
    with :a_section, :an_article do
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
    action { get :comments, params_from("/a-section/articles/a-section-article.atom") }
  
    with :a_section, :an_article do
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