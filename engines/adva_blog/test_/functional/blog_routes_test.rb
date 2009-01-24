require File.expand_path(File.dirname(__FILE__) + "/../test_helper")

class BlogRoutesTest < ActionController::TestCase
  tests BlogController
  with_common :a_blog, :a_category, :an_article

  describe "routing" do
    ['', '/a-blog', '/de', '/de/a-blog'].each do |path_prefix|
      ['', '/pages/2'].each do |path_suffix|
  
        common = { :section_id => Blog.first.id.to_s, :path_prefix => path_prefix, :path_suffix => path_suffix }
        common.merge! :locale => 'de' if path_prefix =~ /de/
        common.merge! :page => 2      if path_suffix =~ /pages/
  
        with_options common do |r|
          r.it_maps :get, '/',                         :action => 'index'
          r.it_maps :get, '/2000',                     :action => 'index', :year => '2000'
          r.it_maps :get, '/2000/1',                   :action => 'index', :year => '2000', :month => '1'
  
          r.it_maps :get, '/categories/foo',           :action => 'index', :category_id => 'foo'
          r.it_maps :get, '/categories/foo/2000',      :action => 'index', :category_id => 'foo', :year => '2000'
          r.it_maps :get, '/categories/foo/2000/1',    :action => 'index', :category_id => 'foo', :year => '2000', :month => '1'
  
          r.it_maps :get, '/tags/foo+bar',             :action => 'index', :tags => 'foo+bar'
          r.it_maps :get, '/tags/foo+bar/2000',        :action => 'index', :tags => 'foo+bar', :year => '2000'
          r.it_maps :get, '/tags/foo+bar/2000/1',      :action => 'index', :tags => 'foo+bar', :year => '2000', :month => '1'
  
          unless path_suffix =~ /pages/
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
        end
      end
    end
  
    # these do not work with a root section path because there's a reguar Comments resource
    with_options :action => 'comments', :format => 'atom', :section_id => Blog.first.id.to_s do |r|
      r.it_maps :get, '/a-blog/comments.atom'
      r.it_maps :get, '/de/a-blog/comments.atom', :locale => 'de'
    end
  end

  describe "the url_helper blog_path" do
    before do
      other = @section.site.sections.create! :title => 'another section' # FIXME move to db/populate
      other.move_to_left_of @section

      url_rewriter = ActionController::UrlRewriter.new @request, params_from('/de/blog')
      @controller.instance_variable_set :@url, url_rewriter
      @controller.instance_variable_set :@site, @site

      I18n.default_locale = :en
      I18n.locale = :de
    end

    blog_path               = lambda { blog_path(@section) }
    archive_path            = lambda { blog_path(@section, :year => '2008', :month => '1') }
    tag_path                = lambda { blog_tag_path(@section, 'foo+bar') }
    category_path           = lambda { blog_category_path(@section, @category) }

    paged_blog_path         = lambda { blog_path(@section, :page => 2) }
    paged_archive_path      = lambda { blog_path(@section, :year => '2008', :month => '1', :page => 2) }
    paged_tag_path          = lambda { blog_tag_path(@section, 'foo+bar', :page => 2) }
    paged_category_path     = lambda { blog_category_path(@section, @category, :page => 2) }

    formatted_blog_path     = lambda { formatted_blog_path(@section, :rss) }
    formatted_tag_path      = lambda { formatted_blog_tag_path(@section, 'foo+bar', :rss) }
    formatted_category_path = lambda { formatted_blog_category_path(@section, @category, :rss) }

    article_path            = lambda { article_path(@section, @article.full_permalink) }
    formatted_article_path  = lambda { formatted_blog_article_comments_path(@section, @article.full_permalink.merge(:format => :rss)) }

    it_rewrites blog_path,               :to => '/',                                       :with => [:is_default_locale, :is_root_section]
    it_rewrites blog_path,               :to => '/de',                                     :with => [:is_root_section]
    it_rewrites blog_path,               :to => '/a-blog',                                 :with => [:is_default_locale]
    it_rewrites blog_path,               :to => '/de/a-blog'

    it_rewrites archive_path,            :to => '/2008/1',                                 :with => [:is_default_locale, :is_root_section]
    it_rewrites archive_path,            :to => '/de/2008/1',                              :with => [:is_root_section]
    it_rewrites archive_path,            :to => '/a-blog/2008/1',                          :with => [:is_default_locale]
    it_rewrites archive_path,            :to => '/de/a-blog/2008/1'

    it_rewrites tag_path,                :to => '/tags/foo+bar',                           :with => [:is_default_locale, :is_root_section]
    it_rewrites tag_path,                :to => '/de/tags/foo+bar',                        :with => [:is_root_section]
    it_rewrites tag_path,                :to => '/a-blog/tags/foo+bar',                    :with => [:is_default_locale]
    it_rewrites tag_path,                :to => '/de/a-blog/tags/foo+bar'

    it_rewrites category_path,           :to => '/categories/a-category',                  :with => [:is_default_locale, :is_root_section]
    it_rewrites category_path,           :to => '/de/categories/a-category',               :with => [:is_root_section]
    it_rewrites category_path,           :to => '/a-blog/categories/a-category',           :with => [:is_default_locale]
    it_rewrites category_path,           :to => '/de/a-blog/categories/a-category'

    it_rewrites paged_blog_path,         :to => '/de/a-blog/pages/2'
    it_rewrites paged_archive_path,      :to => '/de/a-blog/2008/1/pages/2'
    it_rewrites paged_tag_path,          :to => '/de/a-blog/tags/foo+bar/pages/2'
    it_rewrites paged_category_path,     :to => '/de/a-blog/categories/a-category/pages/2'

    it_rewrites formatted_blog_path,     :to => '/a-blog.rss',                            :with => [:is_default_locale, :is_root_section]
    it_rewrites formatted_blog_path,     :to => '/de/a-blog.rss',                         :with => [:is_root_section]
    it_rewrites formatted_blog_path,     :to => '/a-blog.rss',                            :with => [:is_default_locale]
    it_rewrites formatted_blog_path,     :to => '/de/a-blog.rss'

    it_rewrites formatted_tag_path,      :to => '/tags/foo+bar.rss',                      :with => [:is_default_locale, :is_root_section]
    it_rewrites formatted_tag_path,      :to => '/de/tags/foo+bar.rss',                   :with => [:is_root_section]
    it_rewrites formatted_tag_path,      :to => '/a-blog/tags/foo+bar.rss',               :with => [:is_default_locale]
    it_rewrites formatted_tag_path,      :to => '/de/a-blog/tags/foo+bar.rss'

    it_rewrites formatted_category_path, :to => '/categories/a-category.rss',             :with => [:is_default_locale, :is_root_section]
    it_rewrites formatted_category_path, :to => '/de/categories/a-category.rss',          :with => [:is_root_section]
    it_rewrites formatted_category_path, :to => '/a-blog/categories/a-category.rss',      :with => [:is_default_locale]
    it_rewrites formatted_category_path, :to => '/de/a-blog/categories/a-category.rss'

    it_rewrites article_path,            :to => '/2008/1/1/a-blog-article',               :with => [:is_default_locale, :is_root_section]
    it_rewrites article_path,            :to => '/de/2008/1/1/a-blog-article',            :with => [:is_root_section]
    it_rewrites article_path,            :to => '/a-blog/2008/1/1/a-blog-article',        :with => [:is_default_locale]
    it_rewrites article_path,            :to => '/de/a-blog/2008/1/1/a-blog-article'

    it_rewrites formatted_article_path,  :to => '/2008/1/1/a-blog-article.rss',           :with => [:is_default_locale, :is_root_section]
    it_rewrites formatted_article_path,  :to => '/de/2008/1/1/a-blog-article.rss',        :with => [:is_root_section]
    it_rewrites formatted_article_path,  :to => '/a-blog/2008/1/1/a-blog-article.rss',    :with => [:is_default_locale]
    it_rewrites formatted_article_path,  :to => '/de/a-blog/2008/1/1/a-blog-article.rss'
  end
end