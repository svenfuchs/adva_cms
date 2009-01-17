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
  
  # FIXME test url_helper rewriting/filtering

  # describe "the url_helper blog_path" do
  #   before :each do
  #     url_rewriter = ActionController::UrlRewriter.new @request, params_from(:get, '/de/blog')
  #     @controller.instance_variable_set :@url, url_rewriter
  #     @controller.stub!(:site).and_return @site
  #     @current_section = @blog
  #   end
  # 
  #   @blog_path               = lambda { blog_path(@blog) }
  #   @archive_path            = lambda { blog_path(@blog, :year => '2008', :month => '1') }
  #   @tag_path                = lambda { blog_tag_path(@blog, 'foo+bar') }
  #   @category_path           = lambda { blog_category_path(@blog, @category) }
  # 
  #   @paged_blog_path         = lambda { blog_path(@blog, :page => 2) }
  #   @paged_archive_path      = lambda { blog_path(@blog, :year => '2008', :month => '1', :page => 2) }
  #   @paged_tag_path          = lambda { blog_tag_path(@blog, 'foo+bar', :page => 2) }
  #   @paged_category_path     = lambda { blog_category_path(@blog, @category, :page => 2) }
  # 
  #   @formatted_blog_path     = lambda { formatted_blog_path(@blog, :rss) }
  #   @formatted_tag_path      = lambda { formatted_blog_tag_path(@blog, 'foo+bar', :rss) }
  #   @formatted_category_path = lambda { formatted_blog_category_path(@blog, @category, :rss) }
  # 
  #   @article_path            = lambda { article_path(@blog, @article.full_permalink) }
  #   @formatted_article_path  = lambda { formatted_blog_article_comments_path(@blog, @article.full_permalink.merge(:format => :rss)) }
  # 
  #   rewrites_url @blog_path,               :to => '/',                             :on => [:default_locale, :root_section]
  #   rewrites_url @blog_path,               :to => '/de',                           :on => [:root_section]
  #   rewrites_url @blog_path,               :to => '/blog',                         :on => [:default_locale]
  #   rewrites_url @blog_path,               :to => '/de/blog'
  # 
  #   rewrites_url @archive_path,            :to => '/2008/1',                       :on => [:default_locale, :root_section]
  #   rewrites_url @archive_path,            :to => '/de/2008/1',                    :on => [:root_section]
  #   rewrites_url @archive_path,            :to => '/blog/2008/1',                  :on => [:default_locale]
  #   rewrites_url @archive_path,            :to => '/de/blog/2008/1'
  # 
  #   rewrites_url @tag_path,                :to => '/tags/foo+bar',                 :on => [:default_locale, :root_section]
  #   rewrites_url @tag_path,                :to => '/de/tags/foo+bar',              :on => [:root_section]
  #   rewrites_url @tag_path,                :to => '/blog/tags/foo+bar',            :on => [:default_locale]
  #   rewrites_url @tag_path,                :to => '/de/blog/tags/foo+bar'
  # 
  #   rewrites_url @category_path,           :to => '/categories/foo',               :on => [:default_locale, :root_section]
  #   rewrites_url @category_path,           :to => '/de/categories/foo',            :on => [:root_section]
  #   rewrites_url @category_path,           :to => '/blog/categories/foo',          :on => [:default_locale]
  #   rewrites_url @category_path,           :to => '/de/blog/categories/foo'
  # 
  #   rewrites_url @paged_blog_path,         :to => '/de/blog/pages/2'
  #   rewrites_url @paged_archive_path,      :to => '/de/blog/2008/1/pages/2'
  #   rewrites_url @paged_tag_path,          :to => '/de/blog/tags/foo+bar/pages/2'
  #   rewrites_url @paged_category_path,     :to => '/de/blog/categories/foo/pages/2'
  # 
  #   rewrites_url @formatted_blog_path,     :to => '/blog.rss',                     :on => [:default_locale, :root_section]
  #   rewrites_url @formatted_blog_path,     :to => '/de/blog.rss',                  :on => [:root_section]
  #   rewrites_url @formatted_blog_path,     :to => '/blog.rss',                     :on => [:default_locale]
  #   rewrites_url @formatted_blog_path,     :to => '/de/blog.rss'
  # 
  #   rewrites_url @formatted_tag_path,      :to => '/tags/foo+bar.rss',             :on => [:default_locale, :root_section]
  #   rewrites_url @formatted_tag_path,      :to => '/de/tags/foo+bar.rss',          :on => [:root_section]
  #   rewrites_url @formatted_tag_path,      :to => '/blog/tags/foo+bar.rss',        :on => [:default_locale]
  #   rewrites_url @formatted_tag_path,      :to => '/de/blog/tags/foo+bar.rss'
  # 
  #   rewrites_url @formatted_category_path, :to => '/categories/foo.rss',           :on => [:default_locale, :root_section]
  #   rewrites_url @formatted_category_path, :to => '/de/categories/foo.rss',        :on => [:root_section]
  #   rewrites_url @formatted_category_path, :to => '/blog/categories/foo.rss',      :on => [:default_locale]
  #   rewrites_url @formatted_category_path, :to => '/de/blog/categories/foo.rss'
  # 
  #   rewrites_url @article_path,            :to => '/2008/1/1/an-article',            :on => [:default_locale, :root_section]
  #   rewrites_url @article_path,            :to => '/de/2008/1/1/an-article',         :on => [:root_section]
  #   rewrites_url @article_path,            :to => '/blog/2008/1/1/an-article',       :on => [:default_locale]
  #   rewrites_url @article_path,            :to => '/de/blog/2008/1/1/an-article'
  # 
  #   rewrites_url @formatted_article_path,  :to => '/2008/1/1/an-article.rss',        :on => [:default_locale, :root_section]
  #   rewrites_url @formatted_article_path,  :to => '/de/2008/1/1/an-article.rss',     :on => [:root_section]
  #   rewrites_url @formatted_article_path,  :to => '/blog/2008/1/1/an-article.rss',   :on => [:default_locale]
  #   rewrites_url @formatted_article_path,  :to => '/de/blog/2008/1/1/an-article.rss'
  # end
end