require File.expand_path(File.dirname(__FILE__) + "/../test_helper")

class WikiRoutesTest < ActionController::TestCase
  tests WikiController
  with_common :a_wiki, :a_wikipage
  
  describe "routing" do
    with :a_wikipage_category do
      # FIXME what about paged routes, e.g. /wiki/pages/page/1 ??
      
      ['', '/a-wiki', '/de', '/de/a-wiki'].each do |path_prefix|
        
        common = { :section_id => Wiki.first.id.to_s, :path_prefix => path_prefix } # , :path_suffix => path_suffix
        common.merge! :locale => 'de' if path_prefix =~ /de/

        with_options common do |r|
          r.it_maps :get,    '/',                              :action => 'show'
          r.it_maps :get,    '/pages/a-wikipage',              :action => 'show', :id => 'a-wikipage'
          r.it_maps :get,    '/pages',                         :action => 'index'
          r.it_maps :get,    '/pages/a-wikipage/rev/1',        :action => 'show', :id => 'a-wikipage', :version => '1'
          r.it_maps :get,    '/pages/a-wikipage/diff/1',       :action => 'diff', :id => 'a-wikipage', :diff_version => '1'
          r.it_maps :get,    '/pages/a-wikipage/rev/1/diff/1', :action => 'diff', :id => 'a-wikipage', :diff_version => '1', :version => '1'
          r.it_maps :get,    '/categories/a-category',         :action => 'index', :category_id => Wiki.first.categories.first.id.to_s
          r.it_maps :get,    '/tags/foo+bar',                  :action => 'index', :tags => 'foo+bar'
          r.it_maps :post,   '/pages',                         :action => 'create'
          r.it_maps :get,    '/pages/new',                     :action => 'new'
          r.it_maps :get,    '/pages/a-wikipage/edit',         :action => 'edit',    :id => 'a-wikipage'
          r.it_maps :put,    '/pages/a-wikipage',              :action => 'update',  :id => 'a-wikipage'
          r.it_maps :delete, '/pages/a-wikipage',              :action => 'destroy', :id => 'a-wikipage'
        end
      end
        
      with_options :section_id => Wiki.first.id.to_s, :format => 'atom' do |r|
        r.it_maps :get, '/a-wiki/comments.atom',                  :action => 'comments'
        r.it_maps :get, '/a-wiki/pages/a-wikipage/comments.atom', :action => 'comments', :id => 'a-wikipage'
        r.it_maps :get, '/pages/a-wikipage/comments.atom',        :action => 'comments', :id => 'a-wikipage'
      end
    end
  end

  # FIXME test url_helper rewriting/filtering

  # describe "the url_helper wiki_path" do
  #   before :each do
  #     url_rewriter = ActionController::UrlRewriter.new @request, params_from(:get, '/de/wiki')
  #     @controller.instance_variable_set :@url, url_rewriter
  #     @current_section = @wiki
  #     @controller.stub!(:site).and_return @site
  #   end
  # 
  #   @wiki_path               = lambda { wiki_path(@wiki) }
  #   @tag_path                = lambda { wiki_tag_path(@wiki, 'foo+bar') }
  #   @category_path           = lambda { wiki_category_path(@wiki, @category) }
  # 
  #   @formatted_wiki_path     = lambda { formatted_wiki_path(@wiki, :rss) }
  #   @formatted_tag_path      = lambda { formatted_wiki_tag_path(@wiki, 'foo+bar', :rss) }
  #   @formatted_category_path = lambda { formatted_wiki_category_path(@wiki, @category, :rss) }
  # 
  #   @wikipage_path           = lambda { wikipage_path(@wiki, @wikipage.permalink) }
  #   @formatted_wikipage_path = lambda { formatted_wikipage_path(@wiki, @wikipage.permalink, :rss) }
  # 
  # 
  #   rewrites_url @wiki_path,               :to => '/',                               :on => [:default_locale, :root_section]
  #   rewrites_url @wiki_path,               :to => '/wiki',                           :on => [:default_locale]
  #   rewrites_url @wiki_path,               :to => '/de',                             :on => [:root_section]
  #   rewrites_url @wiki_path,               :to => '/de/wiki'
  # 
  #   rewrites_url @tag_path,                :to => '/tags/foo+bar',                   :on => [:default_locale, :root_section]
  #   rewrites_url @tag_path,                :to => '/de/tags/foo+bar',                :on => [:root_section]
  #   rewrites_url @tag_path,                :to => '/wiki/tags/foo+bar',              :on => [:default_locale]
  #   rewrites_url @tag_path,                :to => '/de/wiki/tags/foo+bar'
  # 
  #   rewrites_url @category_path,           :to => '/categories/foo',                 :on => [:default_locale, :root_section]
  #   rewrites_url @category_path,           :to => '/de/categories/foo',              :on => [:root_section]
  #   rewrites_url @category_path,           :to => '/wiki/categories/foo',            :on => [:default_locale]
  #   rewrites_url @category_path,           :to => '/de/wiki/categories/foo'
  # 
  #   # TODO fix this crap
  #   rewrites_url @formatted_wiki_path,     :to => '/wiki.rss',                       :on => [:default_locale, :root_section]
  #   rewrites_url @formatted_wiki_path,     :to => '/de/wiki.rss',                    :on => [:root_section]
  #   rewrites_url @formatted_wiki_path,     :to => '/wiki.rss',                       :on => [:default_locale]
  #   rewrites_url @formatted_wiki_path,     :to => '/de/wiki.rss'
  # 
  #   rewrites_url @formatted_tag_path,      :to => '/tags/foo+bar.rss',               :on => [:default_locale, :root_section]
  #   rewrites_url @formatted_tag_path,      :to => '/de/tags/foo+bar.rss',            :on => [:root_section]
  #   rewrites_url @formatted_tag_path,      :to => '/wiki/tags/foo+bar.rss',          :on => [:default_locale]
  #   rewrites_url @formatted_tag_path,      :to => '/de/wiki/tags/foo+bar.rss'
  # 
  #   rewrites_url @formatted_category_path, :to => '/categories/foo.rss',             :on => [:default_locale, :root_section]
  #   rewrites_url @formatted_category_path, :to => '/de/categories/foo.rss',          :on => [:root_section]
  #   rewrites_url @formatted_category_path, :to => '/wiki/categories/foo.rss',        :on => [:default_locale]
  #   rewrites_url @formatted_category_path, :to => '/de/wiki/categories/foo.rss'
  # 
  #   rewrites_url @wikipage_path,           :to => '/pages/a-wikipage',               :on => [:default_locale, :root_section]
  #   rewrites_url @wikipage_path,           :to => '/de/pages/a-wikipage',            :on => [:root_section]
  #   rewrites_url @wikipage_path,           :to => '/wiki/pages/a-wikipage',          :on => [:default_locale]
  #   rewrites_url @wikipage_path,           :to => '/de/wiki/pages/a-wikipage'
  # 
  #   rewrites_url @formatted_wikipage_path,  :to => '/pages/a-wikipage.rss',          :on => [:default_locale, :root_section]
  #   rewrites_url @formatted_wikipage_path,  :to => '/de/pages/a-wikipage.rss',       :on => [:root_section]
  #   rewrites_url @formatted_wikipage_path,  :to => '/wiki/pages/a-wikipage.rss',     :on => [:default_locale]
  #   rewrites_url @formatted_wikipage_path,  :to => '/de/wiki/pages/a-wikipage.rss'
  # end
  
end