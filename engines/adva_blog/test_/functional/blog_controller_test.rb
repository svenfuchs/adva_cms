require File.expand_path(File.dirname(__FILE__) + "/../test_helper")

class BlogControllerTest < ActionController::TestCase
  with_common :a_blog, :a_category, :an_article

  test "is an BaseController" do
    BaseController.should === @controller # FIXME matchy doesn't have a be_kind_of matcher
  end

  describe "routing" do
    # FIXME test paged routes
    ['/a-blog' ].each do |path_prefix|
      # FIXME how to remove the assumption Blog.first from here?
      with_options :section_id => Blog.first.id.to_s, :path_prefix => path_prefix do |r|

        r.it_maps :get, '/',                         :action => 'index'
        r.it_maps :get, '/2000',                     :action => 'index', :year => '2000'
        r.it_maps :get, '/2000/1',                   :action => 'index', :year => '2000', :month => '1'

        r.it_maps :get, '/categories/foo',           :action => 'index', :category_id => 'foo'
        r.it_maps :get, '/categories/foo/2000',      :action => 'index', :category_id => 'foo', :year => '2000'
        r.it_maps :get, '/categories/foo/2000/1',    :action => 'index', :category_id => 'foo', :year => '2000', :month => '1'

        r.it_maps :get, '/tags/foo+bar',             :action => 'index', :tags => 'foo+bar'
        r.it_maps :get, '/tags/foo+bar/2000',        :action => 'index', :tags => 'foo+bar', :year => '2000'
        r.it_maps :get, '/tags/foo+bar/2000/1',      :action => 'index', :tags => 'foo+bar', :year => '2000', :month => '1'

        r.it_maps :get, '/2000/1/1/an-article',      :action => 'show', :year => '2000', :month => '1', :day => '1',
                                                     :permalink => 'an-article'

        # article feeds
        r.it_maps :get, '.atom',                     :action => 'index', :format => 'atom'
        r.it_maps :get, '/categories/foo.atom',      :action => 'index', :category_id => 'foo', :format => 'atom'
        r.it_maps :get, '/tags/foo+bar.atom',        :action => 'index', :tags => 'foo+bar', :format => 'atom'

        # comment feeds
        r.it_maps :get, '/2000/1/1/an-article.atom', :action => 'comments', :year => '2000', :month => '1', :day => '1',
                                                     :permalink => 'an-article', :format => 'atom'
      end

      # this does only work with a path prefix (as in /blog/comments.atom) because the root_section filter
      # does not kick in for the "comments" segment ... not sure if this can be changed because there's also
      # a regular comments resource

      # FIXME how to remove the assumption Blog.first from here?
      it_maps :get, '/a-blog/comments.atom', :action => 'comments', :section_id => Blog.first.id.to_s, :format => 'atom'
    end
  end

  { :blog_paths              => %w( /a-blog ),
                                    # /a-blog/2008
                                    # /a-blog/2008/1 ),
    :blog_category_paths     => %w( /a-blog/categories/a-category
                                    /a-blog/categories/a-category/2008
                                    /a-blog/categories/a-category/2008/1 ),
    :blog_tag_paths          => %w( /a-blog/tags/foo+bar ),
    :blog_feed_paths         => %w( /a-blog.atom
                                    /a-blog/categories/a-category.atom
                                    /a-blog/tags/foo+bar.atom ),
    :blog_comment_feed_paths => %w( /a-blog/comments.atom
                                    /a-blog/2008/1/1/a-blog-article.atom ) }.each do |type, paths|

    paths.each do |path|
      With.share(type) { before { @params = params_from path } }
    end
  end

  view :index do
    has_tag 'div[class~=entry]' do
      has_tag 'div.meta a', /\d comment[s]?/

      # displays an edit link for authorized users
      has_authorized_tag :a, /edit/i, :href => edit_admin_article_path(@site, @section, @article)

      unless @article.excerpt.blank?
        does_not_have_text 'article body'
        has_text 'article excerpt'
        has_tag :a, /read the rest of this entry/i
      else
        has_text 'article body'
        does_not_have_text 'article excerpt'
        # does_not_have_tag :a, /read the rest of this entry/i
      end
      
      # list the article's categories
      # list the article's tags
    end
  end
  
  view :show do
    # displays title, excerpt and body
    # does not display a 'read more' link
    # list the article's categories
    # list the article's tags

    # displays an edit link for authorized users
    has_authorized_tag :a, /edit/i, :href => edit_admin_article_path(@site, @section, @article)

    # render comments list when article has comments
    # render comment form when article allows commenting
  end

  describe "GET to :index" do
    action { get :index, @params }

    with [:blog_paths, :blog_category_paths, :blog_tag_paths] do
      with [:article_has_an_excerpt, :article_has_no_excerpt] do
        it_assigns :section, :articles
        it_renders :view, :index
        it_caches_the_page :track => ['@article', '@articles', '@category', {'@site' => :tag_counts, '@section' => :tag_counts}]

        it_assigns :category, :in => :'blog_category_paths'
        it_assigns :tags,     :in => :'blog_tag_paths'
      end
    end

    with :'blog_feed_paths' do
      it_assigns :section, :articles
      it_renders :template, :index, :format => :atom
    end
  end

  describe "GET to :show" do
    action { get :show, {:section_id => @section.id}.merge(@article.full_permalink) }

    with :the_article_is_published do
      it_assigns :section, :article
      it_renders :template, :show
      it_caches_the_page :track => ['@article', '@articles', '@category', {'@site' => :tag_counts, '@section' => :tag_counts}]
    end

    # FIXME
    # with "the article is not published" do
    #   raises ActiveRecord::RecordNotFound
    # end
  end

  describe "GET to :comments" do
    action { get :comments, @params }

    with :the_article_is_published do
      with :blog_comment_feed_paths do
        it_assigns :section, :comments
        it_renders :template, 'comments/comments', :format => :atom
      end
    end
  end
end