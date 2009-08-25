require File.expand_path(File.dirname(__FILE__) + "/../test_helper")

class BlogArticlesControllerTest < ActionController::TestCase
  tests BlogArticlesController
  with_common :a_blog, :a_category, :an_article

  test "is an BaseController" do
    @controller.should be_kind_of(BaseController)
  end

  { :blog_paths              => %w( /a-blog
                                    /a-blog/2008
                                    /a-blog/2008/1 ),
    :blog_category_paths     => %w( /a-blog/categories/a-category
                                    /a-blog/categories/a-category/2008
                                    /a-blog/categories/a-category/2008/1 ),
    :blog_tag_paths          => %w( /a-blog/tags/foo+bar ),
    :blog_feed_paths         => %w( /a-blog.atom
                                    /a-blog/categories/a-category.atom
                                    /a-blog/tags/foo+bar.atom ),
    :blog_comment_feed_paths => %w( /a-blog/comments.atom
                                    /a-blog/2008/1/1/a-blog-article.atom ) }.each do |type, paths|

    paths.each { |path| With.share(type) { before { @params = params_from path } } }
  end

  describe "GET to :index" do
    action { get :index, @params }

    with [:blog_paths, :blog_category_paths, :blog_tag_paths] do
      it_assigns :section, :articles
      it_caches_the_page :track => ['@article', '@articles', '@category', {'@site' => :tag_counts, '@section' => :tag_counts}]

      it_assigns :category,         :in => :blog_category_paths
      it_assigns :tags, %(foo bar), :in => :blog_tag_paths

      it_renders :template, :index
    end

    with "a blog path" do
      # splitting this off so we do not test all these combinations on any of the paths above
      before { @params = params_from('/a-blog') }

      it "displays the article" do
        has_tag('div[class~=entry]') { has_permalink @article }
      end

      it "shows the excerpt", :with => :article_has_an_excerpt do
        does_not_have_text 'article body'
        has_text 'article excerpt'
        has_tag 'a', /read the rest of this entry/i
      end

      it "shows the body", :with => :article_has_no_excerpt do
        has_text 'article body'
        does_not_have_text 'article excerpt'
        has_tag 'a', :text => /read the rest of this entry/i, :count => 0
      end

      it "displays the number of comments and links to them", :with => :comments_or_commenting_allowed do
        has_tag 'div.meta a', /\d comment[s]?/i
      end

      it "does not display the number of comments", :with => :no_comments_and_commenting_not_allowed do
        has_tag 'div.meta a', :text => /\d comment[s]?/, :count => 0
      end

      has_tag 'div[id=footer]', :if => :default_theme do
        has_tag 'ul[id=categories_list]'
        has_tag 'ul[id=archives]'
        # has_tag 'ul[id=tags-list]' # FIXME currently tags are not displayed
      end
    end

    with :blog_feed_paths do
      it_assigns :section, :articles
      it_renders :template, :index, :format => :atom
    end
  end

  describe "GET to :show" do
    action { get :show, {:section_id => @section.id}.merge(@article.full_permalink) }

    with :the_article_is_published do
      it_assigns :section, :article
      it_caches_the_page :track => ['@article', '@articles', '@category', {'@site' => :tag_counts, '@section' => :tag_counts}]

      it_renders :template, :show do
        has_tag 'div[class~=entry]' do
          # displays the title and links it to the article
          has_permalink @article

          # displays excerpt and body
          has_text @article.excerpt
          has_text @article.body

          # displays an edit link for authorized users
          has_authorized_tag 'a[href=?]', edit_admin_article_path(@site, @section, @article), /edit/i

          # does not display a 'read more' link
          assert @response.body !~ /read the rest of this entry/i

          # FIXME
          # lists the article's categories
          # lists the article's tags
        end
      end

      # FIXME
      # when article has an approved comment: shows the comment
      # when article has an unapproved comment: does not show any comments
      # when article does not have any comments: does not show any comments
      #
      # when article allows commenting: shows comment form
      # when article does not allow commenting: does not show comment form
    end

    # FIXME
    # with "the article is not published" do
    #   when the user does not have edit permissions: 404, raises ActiveRecord::RecordNotFound
    #   when the user has edit permissions: renders show template, does not cache the page
    # end

    # FIXME
    # with a permalink that does not point to an article: raises ActiveRecord::RecordNotFound
  end

  describe "GET to :comments" do
    action { get :comments, @params }

    with :the_article_is_published do
      with :blog_comment_feed_paths do
        # FIXME it_caches_the_page ...
        it_assigns :section, :comments
        it_renders :template, 'comments/comments', :format => :atom
      end
    end
  end
end