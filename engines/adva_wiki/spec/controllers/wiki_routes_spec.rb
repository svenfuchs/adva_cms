require File.dirname(__FILE__) + "/../spec_helper"

describe WikiController do
  include SpecControllerHelper
  with_routing_filter

  before :each do
    stub_scenario :wiki_with_wikipages

    controller.instance_variable_set :@site, @site
  end

  describe "routing" do
    with_options :section_id => '1' do |r|
      r.maps_to_show '/'
      r.maps_to_show '/wiki'
      r.maps_to_show '/de', :locale => 'de'
      r.maps_to_show '/de/wiki', :locale => 'de'

      r.maps_to_index '/tags/foo+bar', :tags => 'foo+bar'
      r.maps_to_index '/de/tags/foo+bar', :locale => 'de', :tags => 'foo+bar'
      r.maps_to_index '/wiki/tags/foo+bar', :tags => 'foo+bar'
      r.maps_to_index '/de/wiki/tags/foo+bar', :locale => 'de', :tags => 'foo+bar'

      r.maps_to_index '/categories/foo', :category_id => '1'
      r.maps_to_index '/de/categories/foo', :locale => 'de', :category_id => '1'

      # pretty sure this is an error in the specs. the category route filter should rewrite :foo to 1
      r.maps_to_index '/wiki/categories/foo', :category_id => '1'
      r.maps_to_index '/de/wiki/categories/foo', :locale => 'de', :category_id => '1'

      r.maps_to_show '/pages/a-page', :id => 'a-page'
      r.maps_to_show '/de/pages/a-page', :locale => 'de', :id => 'a-page'
      r.maps_to_show '/wiki/pages/a-page', :id => 'a-page'
      r.maps_to_show '/de/wiki/pages/a-page', :locale => 'de', :id => 'a-page'
    end

    with_options :section_id => '1', :format => 'rss' do |r|
      r.maps_to_index '/wiki.rss'

      r.maps_to_index '/categories/foo.rss', :category_id => '1'
      r.maps_to_index '/wiki/categories/foo.rss', :category_id => '1'

      r.maps_to_index '/tags/foo+bar.rss', :tags => 'foo+bar'
      r.maps_to_index '/wiki/tags/foo+bar.rss', :tags => 'foo+bar'

      r.maps_to_show '/pages/a-page.rss', :id => 'a-page'
      r.maps_to_show '/wiki/pages/a-page.rss', :id => 'a-page'

      r.maps_to_index '/de.rss', :locale => 'de'
      r.maps_to_index '/de/wiki.rss', :locale => 'de'

      r.maps_to_index '/de/categories/foo.rss', :locale => 'de', :category_id => '1'
      r.maps_to_index '/de/wiki/categories/foo.rss', :locale => 'de', :category_id => '1'

      r.maps_to_index '/de/tags/foo+bar.rss', :locale => 'de', :tags => 'foo+bar'
      r.maps_to_index '/de/wiki/tags/foo+bar.rss', :locale => 'de', :tags => 'foo+bar'

      r.maps_to_show '/de/pages/a-page.rss', :locale => 'de', :id => 'a-page'
      r.maps_to_show '/de/wiki/pages/a-page.rss', :locale => 'de', :id => 'a-page'
    end

    with_options :section_id => '1', :format => 'rss' do |r|
      r.maps_to_action '/wiki/comments.rss', :comments
      r.maps_to_action '/de/pages/a-page/comments.rss', :comments, :locale => 'de', :id => 'a-page'
      r.maps_to_action '/de/wiki/pages/a-page/comments.rss', :comments, :locale => 'de', :id => 'a-page'
    end
  end

  describe "the url_helper wiki_path" do
    before :each do
      url_rewriter = ActionController::UrlRewriter.new @request, params_from(:get, '/de/wiki')
      @controller.instance_variable_set :@url, url_rewriter
      @current_section = @wiki
      @controller.stub!(:site).and_return @site
    end

    @wiki_path               = lambda { wiki_path(@wiki) }
    @tag_path                = lambda { wiki_tag_path(@wiki, 'foo+bar') }
    @category_path           = lambda { wiki_category_path(@wiki, @category) }

    @formatted_wiki_path     = lambda { formatted_wiki_path(@wiki, :rss) }
    @formatted_tag_path      = lambda { formatted_wiki_tag_path(@wiki, 'foo+bar', :rss) }
    @formatted_category_path = lambda { formatted_wiki_category_path(@wiki, @category, :rss) }

    @wikipage_path           = lambda { wikipage_path(@wiki, @wikipage.permalink) }
    @formatted_wikipage_path = lambda { formatted_wikipage_path(@wiki, @wikipage.permalink, :rss) }


    rewrites_url @wiki_path,               :to => '/',                               :on => [:default_locale, :root_section]
    rewrites_url @wiki_path,               :to => '/wiki',                           :on => [:default_locale]
    rewrites_url @wiki_path,               :to => '/de',                             :on => [:root_section]
    rewrites_url @wiki_path,               :to => '/de/wiki'

    rewrites_url @tag_path,                :to => '/tags/foo+bar',                   :on => [:default_locale, :root_section]
    rewrites_url @tag_path,                :to => '/de/tags/foo+bar',                :on => [:root_section]
    rewrites_url @tag_path,                :to => '/wiki/tags/foo+bar',              :on => [:default_locale]
    rewrites_url @tag_path,                :to => '/de/wiki/tags/foo+bar'

    rewrites_url @category_path,           :to => '/categories/foo',                 :on => [:default_locale, :root_section]
    rewrites_url @category_path,           :to => '/de/categories/foo',              :on => [:root_section]
    rewrites_url @category_path,           :to => '/wiki/categories/foo',            :on => [:default_locale]
    rewrites_url @category_path,           :to => '/de/wiki/categories/foo'

    # TODO fix this crap
    rewrites_url @formatted_wiki_path,     :to => '/wiki.rss',                       :on => [:default_locale, :root_section]
    rewrites_url @formatted_wiki_path,     :to => '/de/wiki.rss',                    :on => [:root_section]
    rewrites_url @formatted_wiki_path,     :to => '/wiki.rss',                       :on => [:default_locale]
    rewrites_url @formatted_wiki_path,     :to => '/de/wiki.rss'

    rewrites_url @formatted_tag_path,      :to => '/tags/foo+bar.rss',               :on => [:default_locale, :root_section]
    rewrites_url @formatted_tag_path,      :to => '/de/tags/foo+bar.rss',            :on => [:root_section]
    rewrites_url @formatted_tag_path,      :to => '/wiki/tags/foo+bar.rss',          :on => [:default_locale]
    rewrites_url @formatted_tag_path,      :to => '/de/wiki/tags/foo+bar.rss'

    rewrites_url @formatted_category_path, :to => '/categories/foo.rss',             :on => [:default_locale, :root_section]
    rewrites_url @formatted_category_path, :to => '/de/categories/foo.rss',          :on => [:root_section]
    rewrites_url @formatted_category_path, :to => '/wiki/categories/foo.rss',        :on => [:default_locale]
    rewrites_url @formatted_category_path, :to => '/de/wiki/categories/foo.rss'

    rewrites_url @wikipage_path,           :to => '/pages/a-wikipage',               :on => [:default_locale, :root_section]
    rewrites_url @wikipage_path,           :to => '/de/pages/a-wikipage',            :on => [:root_section]
    rewrites_url @wikipage_path,           :to => '/wiki/pages/a-wikipage',          :on => [:default_locale]
    rewrites_url @wikipage_path,           :to => '/de/wiki/pages/a-wikipage'

    rewrites_url @formatted_wikipage_path,  :to => '/pages/a-wikipage.rss',          :on => [:default_locale, :root_section]
    rewrites_url @formatted_wikipage_path,  :to => '/de/pages/a-wikipage.rss',       :on => [:root_section]
    rewrites_url @formatted_wikipage_path,  :to => '/wiki/pages/a-wikipage.rss',     :on => [:default_locale]
    rewrites_url @formatted_wikipage_path,  :to => '/de/wiki/pages/a-wikipage.rss'
  end
end