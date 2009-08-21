require File.expand_path(File.dirname(__FILE__) + "/../test_helper")

class WikiRoutesTest < ActionController::TestCase
  tests WikiController
  with_common :default_routing_filters, :a_wiki, :a_wikipage, :a_wikipage_category

  paths = %W( /wikis/1
              /wikis/1/categories/a-category
              /wikis/1/tags/foo+bar
              /wikis/1/wikipages/a-wikipage
              /wikis/1/wikipages/a-wikipage/rev/1
              /wikis/1/wikipages/a-wikipage/diff/1
              /wikis/1/wikipages/a-wikipage/rev/1/diff/1
              /wikis/1/comments.atom
              /wikis/1/wikipages/a-wikipage/comments.atom )

  paths.each do |path|
    test "regenerates the original path from the recognized params for #{path}" do
      without_routing_filters do
        params = ActionController::Routing::Routes.recognize_path(path, :method => :get)
        assert_equal path, @controller.url_for(params.merge(:only_path => true))
      end
    end
  end

  describe "routing" do
    with :a_wikipage_category do
      # FIXME what about paged routes, e.g. /a-wiki/wikipages/page/1 ??
  
      ['/', '/a-wiki', '/de', '/de/a-wiki'].each do |path_prefix|
  
        common = { :section_id => Wiki.first.id.to_s, :path_prefix => path_prefix } # , :path_suffix => path_suffix
        common.merge! :locale => 'de' if path_prefix =~ /de/
  
        with_options common do |r|
          r.it_maps :get,    '',                                   :action => 'show'
          r.it_maps :get,    '/wikipages/a-wikipage',              :action => 'show',    :id => 'a-wikipage'
          r.it_maps :get,    '/wikipages',                         :action => 'index'
          r.it_maps :get,    '/wikipages/a-wikipage/rev/1',        :action => 'show',    :id => 'a-wikipage', :version => '1'
          r.it_maps :get,    '/wikipages/a-wikipage/diff/1',       :action => 'diff',    :id => 'a-wikipage', :diff_version => '1'
          r.it_maps :get,    '/wikipages/a-wikipage/rev/1/diff/1', :action => 'diff',    :id => 'a-wikipage', :diff_version => '1', :version => '1'
          r.it_maps :get,    '/categories/a-category',             :action => 'index',   :category_id => Wiki.first.categories.first.id.to_s
          r.it_maps :get,    '/tags/foo+bar',                      :action => 'index',   :tags => 'foo+bar'
          r.it_maps :post,   '/wikipages',                         :action => 'create'
          r.it_maps :get,    '/wikipages/new',                     :action => 'new'
          r.it_maps :get,    '/wikipages/a-wikipage/edit',         :action => 'edit',    :id => 'a-wikipage'
          r.it_maps :put,    '/wikipages/a-wikipage',              :action => 'update',  :id => 'a-wikipage'
          r.it_maps :delete, '/wikipages/a-wikipage',              :action => 'destroy', :id => 'a-wikipage'
        end
      end
  
      with_options :section_id => Wiki.first.id.to_s, :format => 'atom' do |r|
        r.it_maps :get, '/a-wiki/comments.atom',                  :action => 'comments'
        r.it_maps :get, '/a-wiki/wikipages/a-wikipage/comments.atom', :action => 'comments', :id => 'a-wikipage'
        r.it_maps :get, '/wikipages/a-wikipage/comments.atom',        :action => 'comments', :id => 'a-wikipage'
      end
    end
  end
  
  describe "the url_helper wiki_path" do
    before :each do
      @wikipage = Wikipage.find_by_title 'another wikipage title'
  
      other = @section.site.sections.create! :title => 'another section' # FIXME move to db/populate
      other.move_to_left_of @section
  
      url_rewriter = ActionController::UrlRewriter.new @request, :controller => 'wiki', :section => @section.id
      @controller.instance_variable_set :@url, url_rewriter
      @controller.instance_variable_set :@site, @site
  
      I18n.default_locale = :en
      I18n.locale = :de
    end
  
    wiki_path          = lambda { path = wiki_path(@section) }
    tag_path           = lambda { wiki_tag_path(@section, 'foo+bar') }
    category_path      = lambda { wiki_category_path(@section, @category) }
  
    wiki_feed_path     = lambda { wiki_path(@section, :format => :rss) }
    tag_feed_path      = lambda { wiki_tag_path(@section, 'foo+bar', :format => :rss) }
    category_feed_path = lambda { wiki_category_path(@section, @category, :format => :rss) }
  
    wikipage_path      = lambda { wikipage_path(@section, @wikipage) }
    wikipage_feed_path = lambda { wikipage_path(@section, @wikipage, :format => :rss) }
  
    it_rewrites wiki_path,          :to => '/',                                    :with => [:is_default_locale, :is_root_section]
    it_rewrites wiki_path,          :to => '/a-wiki',                              :with => [:is_default_locale]
    it_rewrites wiki_path,          :to => '/de',                                  :with => [:is_root_section]
    it_rewrites wiki_path,          :to => '/de/a-wiki'
  
    it_rewrites tag_path,           :to => '/tags/foo+bar',                        :with => [:is_default_locale, :is_root_section]
    it_rewrites tag_path,           :to => '/de/tags/foo+bar',                     :with => [:is_root_section]
    it_rewrites tag_path,           :to => '/a-wiki/tags/foo+bar',                 :with => [:is_default_locale]
    it_rewrites tag_path,           :to => '/de/a-wiki/tags/foo+bar'
  
    it_rewrites category_path,      :to => '/categories/a-category',               :with => [:is_default_locale, :is_root_section]
    it_rewrites category_path,      :to => '/de/categories/a-category',            :with => [:is_root_section]
    it_rewrites category_path,      :to => '/a-wiki/categories/a-category',        :with => [:is_default_locale]
    it_rewrites category_path,      :to => '/de/a-wiki/categories/a-category'
  
    it_rewrites wiki_feed_path,     :to => '/a-wiki.rss',                          :with => [:is_default_locale, :is_root_section]
    it_rewrites wiki_feed_path,     :to => '/de/a-wiki.rss',                       :with => [:is_root_section]
    it_rewrites wiki_feed_path,     :to => '/a-wiki.rss',                          :with => [:is_default_locale]
    it_rewrites wiki_feed_path,     :to => '/de/a-wiki.rss'
  
    it_rewrites tag_feed_path,      :to => '/tags/foo+bar.rss',                    :with => [:is_default_locale, :is_root_section]
    it_rewrites tag_feed_path,      :to => '/de/tags/foo+bar.rss',                 :with => [:is_root_section]
    it_rewrites tag_feed_path,      :to => '/a-wiki/tags/foo+bar.rss',             :with => [:is_default_locale]
    it_rewrites tag_feed_path,      :to => '/de/a-wiki/tags/foo+bar.rss'
  
    it_rewrites category_feed_path, :to => '/categories/a-category.rss',           :with => [:is_default_locale, :is_root_section]
    it_rewrites category_feed_path, :to => '/de/categories/a-category.rss',        :with => [:is_root_section]
    it_rewrites category_feed_path, :to => '/a-wiki/categories/a-category.rss',    :with => [:is_default_locale]
    it_rewrites category_feed_path, :to => '/de/a-wiki/categories/a-category.rss'
  
    it_rewrites wikipage_path,      :to => '/wikipages/another-wikipage',               :with => [:is_default_locale, :is_root_section]
    it_rewrites wikipage_path,      :to => '/de/wikipages/another-wikipage',            :with => [:is_root_section]
    it_rewrites wikipage_path,      :to => '/a-wiki/wikipages/another-wikipage',        :with => [:is_default_locale]
    it_rewrites wikipage_path,      :to => '/de/a-wiki/wikipages/another-wikipage'
  
    it_rewrites wikipage_feed_path,  :to => '/wikipages/another-wikipage.rss',          :with => [:is_default_locale, :is_root_section]
    it_rewrites wikipage_feed_path,  :to => '/de/wikipages/another-wikipage.rss',       :with => [:is_root_section]
    it_rewrites wikipage_feed_path,  :to => '/a-wiki/wikipages/another-wikipage.rss',   :with => [:is_default_locale]
    it_rewrites wikipage_feed_path,  :to => '/de/a-wiki/wikipages/another-wikipage.rss'
  end
end