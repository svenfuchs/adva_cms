require File.dirname(__FILE__) + '/../spec_helper'

describe SectionsController do
  include SpecControllerHelper
  with_routing_filter

  before :each do
    stub_scenario :section_with_published_article
    controller.instance_variable_set :@site, @site
  end

  describe "routing" do
    with_options :section_id => '1' do |r|
      r.maps_to_show '/'
      r.maps_to_show '/section'
      r.maps_to_show '/de', :locale => 'de'
      r.maps_to_show '/de/section', :locale => 'de'
    end

    with_options :section_id => '1', :permalink => 'an-article' do |r|
      r.maps_to_show '/articles/an-article'
      r.maps_to_show '/section/articles/an-article'
      r.maps_to_show '/de/articles/an-article', :locale => 'de'
      r.maps_to_show '/de/section/articles/an-article', :locale => 'de'
    end

    with_options :section_id => '1', :format => 'rss' do |r|
      r.maps_to_action '/section/comments.rss', :comments
      r.maps_to_action '/de/articles/an-article.rss', :comments, :locale => 'de', :permalink => 'an-article'
      r.maps_to_action '/de/section/articles/an-article.rss', :comments, :locale => 'de', :permalink => 'an-article'
    end
  end

  describe "the url_helper section_path" do
    before :each do
      url_rewriter = ActionController::UrlRewriter.new @request, params_from(:get, '/de/section')
      @controller.instance_variable_set :@url, url_rewriter
      @controller.stub!(:site).and_return @site
      @current_section = @section
    end

    @section_path = lambda { section_path(@section) }
    @article_path = lambda { section_article_path(@section, 'an-article') }

    rewrites_url @section_path, :to => '/',                     :on => [:default_locale, :root_section]
    rewrites_url @section_path, :to => '/section',              :on => [:default_locale]
    rewrites_url @section_path, :to => '/de',                   :on => [:root_section]
    rewrites_url @section_path, :to => '/de/section'

    rewrites_url @article_path, :to => '/articles/an-article',           :on => [:default_locale, :root_section]
    rewrites_url @article_path, :to => '/section/articles/an-article',   :on => [:default_locale]
    rewrites_url @article_path, :to => '/de/articles/an-article',        :on => [:root_section]
    rewrites_url @article_path, :to => '/de/section/articles/an-article'
  end
end
