require File.expand_path(File.dirname(__FILE__) + "/../test_helper")

class WikiRoutesTest < ActionController::TestCase
  tests WikiController
  with_common :a_wiki, :a_wikipage, :a_wikipage_category

  describe "routing" do
    with :a_wikipage_category do
      # FIXME what about paged routes, e.g. /a-wiki/pages/page/1 ??
  
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

  describe "the url_helper wiki_path" do
    before :each do
      @wikipage = Wikipage.find_by_title 'another wikipage title'

      other = @section.site.sections.create! :title => 'another section' # FIXME move to db/populate
      other.move_to_left_of @section

      url_rewriter = ActionController::UrlRewriter.new @request, params_from('/de/a-wiki')
      @controller.instance_variable_set :@url, url_rewriter
      @controller.instance_variable_set :@site, @site

      I18n.default_locale = :en
      I18n.locale = :de
    end

    wiki_path               = lambda { path = wiki_path(@section) }
    tag_path                = lambda { wiki_tag_path(@section, 'foo+bar') }
    category_path           = lambda { wiki_category_path(@section, @category) }

    formatted_wiki_path     = lambda { formatted_wiki_path(@section, :rss) }
    formatted_tag_path      = lambda { formatted_wiki_tag_path(@section, 'foo+bar', :rss) }
    formatted_category_path = lambda { formatted_wiki_category_path(@section, @category, :rss) }

    wikipage_path           = lambda { wikipage_path(@section, @wikipage.permalink) }
    formatted_wikipage_path = lambda { formatted_wikipage_path(@section, @wikipage.permalink, :rss) }

    it_rewrites wiki_path,               :to => '/',                                     :with => [:is_default_locale, :is_root_section]
    it_rewrites wiki_path,               :to => '/a-wiki',                               :with => [:is_default_locale]
    it_rewrites wiki_path,               :to => '/de',                                   :with => [:is_root_section]
    it_rewrites wiki_path,               :to => '/de/a-wiki'

    it_rewrites tag_path,                :to => '/tags/foo+bar',                         :with => [:is_default_locale, :is_root_section]
    it_rewrites tag_path,                :to => '/de/tags/foo+bar',                      :with => [:is_root_section]
    it_rewrites tag_path,                :to => '/a-wiki/tags/foo+bar',                  :with => [:is_default_locale]
    it_rewrites tag_path,                :to => '/de/a-wiki/tags/foo+bar'

    it_rewrites category_path,           :to => '/categories/a-category',                :with => [:is_default_locale, :is_root_section]
    it_rewrites category_path,           :to => '/de/categories/a-category',             :with => [:is_root_section]
    it_rewrites category_path,           :to => '/a-wiki/categories/a-category',         :with => [:is_default_locale]
    it_rewrites category_path,           :to => '/de/a-wiki/categories/a-category'

    it_rewrites formatted_wiki_path,     :to => '/a-wiki.rss',                           :with => [:is_default_locale, :is_root_section]
    it_rewrites formatted_wiki_path,     :to => '/de/a-wiki.rss',                        :with => [:is_root_section]
    it_rewrites formatted_wiki_path,     :to => '/a-wiki.rss',                           :with => [:is_default_locale]
    it_rewrites formatted_wiki_path,     :to => '/de/a-wiki.rss'

    it_rewrites formatted_tag_path,      :to => '/tags/foo+bar.rss',                     :with => [:is_default_locale, :is_root_section]
    it_rewrites formatted_tag_path,      :to => '/de/tags/foo+bar.rss',                  :with => [:is_root_section]
    it_rewrites formatted_tag_path,      :to => '/a-wiki/tags/foo+bar.rss',              :with => [:is_default_locale]
    it_rewrites formatted_tag_path,      :to => '/de/a-wiki/tags/foo+bar.rss'

    it_rewrites formatted_category_path, :to => '/categories/a-category.rss',            :with => [:is_default_locale, :is_root_section]
    it_rewrites formatted_category_path, :to => '/de/categories/a-category.rss',         :with => [:is_root_section]
    it_rewrites formatted_category_path, :to => '/a-wiki/categories/a-category.rss',     :with => [:is_default_locale]
    it_rewrites formatted_category_path, :to => '/de/a-wiki/categories/a-category.rss'

    it_rewrites wikipage_path,           :to => '/pages/another-wikipage',                :with => [:is_default_locale, :is_root_section]
    it_rewrites wikipage_path,           :to => '/de/pages/another-wikipage',             :with => [:is_root_section]
    it_rewrites wikipage_path,           :to => '/a-wiki/pages/another-wikipage',         :with => [:is_default_locale]
    it_rewrites wikipage_path,           :to => '/de/a-wiki/pages/another-wikipage'

    it_rewrites formatted_wikipage_path,  :to => '/pages/another-wikipage.rss',           :with => [:is_default_locale, :is_root_section]
    it_rewrites formatted_wikipage_path,  :to => '/de/pages/another-wikipage.rss',        :with => [:is_root_section]
    it_rewrites formatted_wikipage_path,  :to => '/a-wiki/pages/another-wikipage.rss',    :with => [:is_default_locale]
    it_rewrites formatted_wikipage_path,  :to => '/de/a-wiki/pages/another-wikipage.rss'
  end
end