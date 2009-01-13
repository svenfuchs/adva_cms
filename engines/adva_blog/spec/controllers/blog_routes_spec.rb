require File.dirname(__FILE__) + "/../spec_helper"

describe BlogController do
  include SpecControllerHelper
  with_routing_filter

  before :each do
    stub_scenario :blog_with_published_article
    controller.instance_variable_set :@site, @site
  end

  describe "routing" do
    with_options :section_id => '1' do |r|
      r.maps_to_index '/'
      r.maps_to_index '/blog'

      r.maps_to_index '/2008', :year => '2008'
      r.maps_to_index '/2008/1', :year => '2008', :month => '1'
      r.maps_to_index '/blog/2008', :year => '2008'
      r.maps_to_index '/blog/2008/1', :year => '2008', :month => '1'

      r.maps_to_index '/categories/foo', :category_id => '1'
      r.maps_to_index '/categories/foo/2008', :category_id => '1', :year => '2008'
      r.maps_to_index '/categories/foo/2008/1', :category_id => '1', :year => '2008', :month => '1'
      r.maps_to_index '/blog/categories/foo', :category_id => '1'
      r.maps_to_index '/blog/categories/foo/2008', :category_id => '1', :year => '2008'
      r.maps_to_index '/blog/categories/foo/2008/1', :category_id => '1', :year => '2008', :month => '1'

      r.maps_to_index '/tags/foo+bar', :tags => 'foo+bar'
      r.maps_to_index '/tags/foo+bar/2008', :tags => 'foo+bar', :year => '2008'
      r.maps_to_index '/tags/foo+bar/2008/1', :tags => 'foo+bar', :year => '2008', :month => '1'
      r.maps_to_index '/blog/tags/foo+bar', :tags => 'foo+bar'
      r.maps_to_index '/blog/tags/foo+bar/2008', :tags => 'foo+bar', :year => '2008'
      r.maps_to_index '/blog/tags/foo+bar/2008/1', :tags => 'foo+bar', :year => '2008', :month => '1'

      r.maps_to_show '/2008/1/1/an-article', :year => '2008', :month => '1', :day => '1', :permalink => 'an-article'
      r.maps_to_show '/blog/2008/1/1/an-article', :year => '2008', :month => '1', :day => '1', :permalink => 'an-article'
    end

    with_options :section_id => '1', :page => 2 do |r|
      r.maps_to_index '/pages/2', :page => 2
      r.maps_to_index '/blog/pages/2', :page => 2

      r.maps_to_index '/2008/pages/2', :year => '2008', :page => 2
      r.maps_to_index '/2008/1/pages/2', :year => '2008', :month => '1', :page => 2
      r.maps_to_index '/blog/2008/pages/2', :year => '2008', :page => 2
      r.maps_to_index '/blog/2008/1/pages/2', :year => '2008', :month => '1', :page => 2

      r.maps_to_index '/categories/foo/pages/2', :category_id => '1', :page => 2
      r.maps_to_index '/categories/foo/2008/pages/2', :category_id => '1', :year => '2008', :page => 2
      r.maps_to_index '/categories/foo/2008/1/pages/2', :category_id => '1', :year => '2008', :month => '1', :page => 2
      r.maps_to_index '/blog/categories/foo/pages/2', :category_id => '1', :page => 2
      r.maps_to_index '/blog/categories/foo/2008/pages/2', :category_id => '1', :year => '2008', :page => 2
      r.maps_to_index '/blog/categories/foo/2008/1/pages/2', :category_id => '1', :year => '2008', :month => '1', :page => 2

      r.maps_to_index '/tags/foo+bar/pages/2', :tags => 'foo+bar', :page => 2
      r.maps_to_index '/tags/foo+bar/2008/pages/2', :tags => 'foo+bar', :year => '2008', :page => 2
      r.maps_to_index '/tags/foo+bar/2008/1/pages/2', :tags => 'foo+bar', :year => '2008', :month => '1', :page => 2
      r.maps_to_index '/blog/tags/foo+bar/pages/2', :tags => 'foo+bar', :page => 2
      r.maps_to_index '/blog/tags/foo+bar/2008/pages/2', :tags => 'foo+bar', :year => '2008', :page => 2
      r.maps_to_index '/blog/tags/foo+bar/2008/1/pages/2', :tags => 'foo+bar', :year => '2008', :month => '1', :page => 2
    end

    with_options :section_id => '1', :locale => 'de' do |r|
      r.maps_to_index '/de'
      r.maps_to_index '/de/blog'

      r.maps_to_index '/de/2008', :year => '2008'
      r.maps_to_index '/de/2008/1', :year => '2008', :month => '1'
      r.maps_to_index '/de/blog/2008', :year => '2008'
      r.maps_to_index '/de/blog/2008/1', :year => '2008', :month => '1'

      r.maps_to_index '/de/categories/foo', :category_id => '1'
      r.maps_to_index '/de/categories/foo/2008', :category_id => '1', :year => '2008'
      r.maps_to_index '/de/categories/foo/2008/1', :category_id => '1', :year => '2008', :month => '1'
      r.maps_to_index '/de/blog/categories/foo', :category_id => '1'
      r.maps_to_index '/de/blog/categories/foo/2008', :category_id => '1', :year => '2008'
      r.maps_to_index '/de/blog/categories/foo/2008/1', :category_id => '1', :year => '2008', :month => '1'

      r.maps_to_index '/de/tags/foo+bar', :tags => 'foo+bar'
      r.maps_to_index '/de/tags/foo+bar/2008', :tags => 'foo+bar', :year => '2008'
      r.maps_to_index '/de/tags/foo+bar/2008/1', :tags => 'foo+bar', :year => '2008', :month => '1'
      r.maps_to_index '/de/blog/tags/foo+bar', :tags => 'foo+bar'
      r.maps_to_index '/de/blog/tags/foo+bar/2008', :tags => 'foo+bar', :year => '2008'
      r.maps_to_index '/de/blog/tags/foo+bar/2008/1', :tags => 'foo+bar', :year => '2008', :month => '1'

      r.maps_to_show '/de/2008/1/1/an-article', :year => '2008', :month => '1', :day => '1', :permalink => 'an-article'
      r.maps_to_show '/de/blog/2008/1/1/an-article', :year => '2008', :month => '1', :day => '1', :permalink => 'an-article'
    end

    with_options :section_id => '1', :format => 'rss' do |r|

      # articles feeds

      r.maps_to_index '/.rss'
      r.maps_to_index '/blog.rss'
      # r.maps_to_index '/blogs/blog.rss'

      r.maps_to_index '/categories/foo.rss', :category_id => '1'
      r.maps_to_index '/blog/categories/foo.rss', :category_id => '1'

      r.maps_to_index '/tags/foo+bar.rss', :tags => 'foo+bar'
      r.maps_to_index '/blog/tags/foo+bar.rss', :tags => 'foo+bar'

      r.maps_to_index '/de.rss', :locale => 'de'
      r.maps_to_index '/de/blog.rss', :locale => 'de'
      # r.maps_to_index '/de/blogs/blog.rss', :locale => 'de'

      r.maps_to_index '/de/categories/foo.rss', :locale => 'de', :category_id => '1'
      r.maps_to_index '/de/blog/categories/foo.rss', :locale => 'de', :category_id => '1'

      r.maps_to_index '/de/tags/foo+bar.rss', :locale => 'de', :tags => 'foo+bar'
      r.maps_to_index '/de/blog/tags/foo+bar.rss', :locale => 'de', :tags => 'foo+bar'

      # comments feeds

      r.maps_to_action '/blog/comments.rss', :comments
      r.maps_to_action '/de/blog/comments.rss', :comments, :locale => 'de'

      r.maps_to_action '/2008/1/1/an-article.rss', :comments, :year => '2008', :month => '1', :day => '1', :permalink => 'an-article'
      r.maps_to_action '/blog/2008/1/1/an-article.rss', :comments, :year => '2008', :month => '1', :day => '1', :permalink => 'an-article'

      r.maps_to_action '/de/2008/1/1/an-article.rss', :comments, :locale => 'de', :year => '2008', :month => '1', :day => '1', :permalink => 'an-article'
      r.maps_to_action '/de/blog/2008/1/1/an-article.rss', :comments, :locale => 'de', :year => '2008', :month => '1', :day => '1', :permalink => 'an-article'
    end
  end

  describe "the url_helper blog_path" do
    before :each do
      url_rewriter = ActionController::UrlRewriter.new @request, params_from(:get, '/de/blog')
      @controller.instance_variable_set :@url, url_rewriter
      @controller.stub!(:site).and_return @site
      @current_section = @blog
    end

    @blog_path               = lambda { blog_path(@blog) }
    @archive_path            = lambda { blog_path(@blog, :year => '2008', :month => '1') }
    @tag_path                = lambda { blog_tag_path(@blog, 'foo+bar') }
    @category_path           = lambda { blog_category_path(@blog, @category) }

    @paged_blog_path         = lambda { blog_path(@blog, :page => 2) }
    @paged_archive_path      = lambda { blog_path(@blog, :year => '2008', :month => '1', :page => 2) }
    @paged_tag_path          = lambda { blog_tag_path(@blog, 'foo+bar', :page => 2) }
    @paged_category_path     = lambda { blog_category_path(@blog, @category, :page => 2) }

    @formatted_blog_path     = lambda { formatted_blog_path(@blog, :rss) }
    @formatted_tag_path      = lambda { formatted_blog_tag_path(@blog, 'foo+bar', :rss) }
    @formatted_category_path = lambda { formatted_blog_category_path(@blog, @category, :rss) }

    @article_path            = lambda { article_path(@blog, @article.full_permalink) }
    @formatted_article_path  = lambda { formatted_blog_article_comments_path(@blog, @article.full_permalink.merge(:format => :rss)) }

    rewrites_url @blog_path,               :to => '/',                             :on => [:default_locale, :root_section]
    rewrites_url @blog_path,               :to => '/de',                           :on => [:root_section]
    rewrites_url @blog_path,               :to => '/blog',                         :on => [:default_locale]
    rewrites_url @blog_path,               :to => '/de/blog'

    rewrites_url @archive_path,            :to => '/2008/1',                       :on => [:default_locale, :root_section]
    rewrites_url @archive_path,            :to => '/de/2008/1',                    :on => [:root_section]
    rewrites_url @archive_path,            :to => '/blog/2008/1',                  :on => [:default_locale]
    rewrites_url @archive_path,            :to => '/de/blog/2008/1'

    rewrites_url @tag_path,                :to => '/tags/foo+bar',                 :on => [:default_locale, :root_section]
    rewrites_url @tag_path,                :to => '/de/tags/foo+bar',              :on => [:root_section]
    rewrites_url @tag_path,                :to => '/blog/tags/foo+bar',            :on => [:default_locale]
    rewrites_url @tag_path,                :to => '/de/blog/tags/foo+bar'

    rewrites_url @category_path,           :to => '/categories/foo',               :on => [:default_locale, :root_section]
    rewrites_url @category_path,           :to => '/de/categories/foo',            :on => [:root_section]
    rewrites_url @category_path,           :to => '/blog/categories/foo',          :on => [:default_locale]
    rewrites_url @category_path,           :to => '/de/blog/categories/foo'

    rewrites_url @paged_blog_path,         :to => '/de/blog/pages/2'
    rewrites_url @paged_archive_path,      :to => '/de/blog/2008/1/pages/2'
    rewrites_url @paged_tag_path,          :to => '/de/blog/tags/foo+bar/pages/2'
    rewrites_url @paged_category_path,     :to => '/de/blog/categories/foo/pages/2'

    rewrites_url @formatted_blog_path,     :to => '/blog.rss',                     :on => [:default_locale, :root_section]
    rewrites_url @formatted_blog_path,     :to => '/de/blog.rss',                  :on => [:root_section]
    rewrites_url @formatted_blog_path,     :to => '/blog.rss',                     :on => [:default_locale]
    rewrites_url @formatted_blog_path,     :to => '/de/blog.rss'

    rewrites_url @formatted_tag_path,      :to => '/tags/foo+bar.rss',             :on => [:default_locale, :root_section]
    rewrites_url @formatted_tag_path,      :to => '/de/tags/foo+bar.rss',          :on => [:root_section]
    rewrites_url @formatted_tag_path,      :to => '/blog/tags/foo+bar.rss',        :on => [:default_locale]
    rewrites_url @formatted_tag_path,      :to => '/de/blog/tags/foo+bar.rss'

    rewrites_url @formatted_category_path, :to => '/categories/foo.rss',           :on => [:default_locale, :root_section]
    rewrites_url @formatted_category_path, :to => '/de/categories/foo.rss',        :on => [:root_section]
    rewrites_url @formatted_category_path, :to => '/blog/categories/foo.rss',      :on => [:default_locale]
    rewrites_url @formatted_category_path, :to => '/de/blog/categories/foo.rss'

    rewrites_url @article_path,            :to => '/2008/1/1/an-article',            :on => [:default_locale, :root_section]
    rewrites_url @article_path,            :to => '/de/2008/1/1/an-article',         :on => [:root_section]
    rewrites_url @article_path,            :to => '/blog/2008/1/1/an-article',       :on => [:default_locale]
    rewrites_url @article_path,            :to => '/de/blog/2008/1/1/an-article'

    rewrites_url @formatted_article_path,  :to => '/2008/1/1/an-article.rss',        :on => [:default_locale, :root_section]
    rewrites_url @formatted_article_path,  :to => '/de/2008/1/1/an-article.rss',     :on => [:root_section]
    rewrites_url @formatted_article_path,  :to => '/blog/2008/1/1/an-article.rss',   :on => [:default_locale]
    rewrites_url @formatted_article_path,  :to => '/de/blog/2008/1/1/an-article.rss'
  end
end