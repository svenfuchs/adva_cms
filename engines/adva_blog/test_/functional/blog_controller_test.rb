require File.expand_path(File.dirname(__FILE__) + "/../test_helper")

class BlogControllerTest < ActionController::TestCase
  with_common :a_blog, :a_category, :an_article

  test "is an BaseController" do
    BaseController.should === @controller # FIXME matchy doesn't have a be_kind_of matcher
  end

  describe "routing" do
    # FIXME test paged routes
    ['', '/blog' ].each do |path_prefix|
      with_options :section_id => "1", :path_prefix => path_prefix do |r|

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
      it_maps :get, '/blog/comments.atom',           :action => 'comments', :section_id => '1', :format => 'atom'
    end
  end

  { :blog_paths              => %w( /blog
                                    /blog/2000
                                    /blog/2000/1 ),
    :blog_category_paths     => %w( /blog/categories/a-category
                                    /blog/categories/a-category/2000
                                    /blog/categories/a-category/2000/1 ),
    :blog_tag_paths          => %w( /blog/tags/foo+bar ),
    :blog_feed_paths         => %w( /blog.atom
                                    /blog/categories/a-category.atom
                                    /blog/tags/foo+bar.atom ),
    :blog_comment_feed_paths => %w( /blog/comments.atom
                                    /blog/2000/1/1/an-article.atom ) }.each do |type, paths|

    paths.each do |path|
      With.share(type) { before { @params = params_from path } }
    end
  end

  describe "GET to :index" do
    action { get :index, @params }

    with [:blog_paths, :blog_category_paths, :blog_tag_paths] do
      it_assigns :section, :articles
      it_renders :template, :index
      it_caches_the_page :track => ['@article', '@articles', '@category', {'@site' => :tag_counts, '@section' => :tag_counts}]

      it_assigns :category, :in => :'params_from blog_category_paths'
      it_assigns :tags,     :in => :'params_from blog_tag_paths'
    end

    with :'blog_feed_paths' do
      it_assigns :section, :articles
      it_renders :template, :index, :format => :atom
    end
  end

  describe "GET to :show" do
    action { get :show, @article.full_permalink }

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