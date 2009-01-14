require File.dirname(__FILE__) + "/../spec_helper"

describe ForumController do
  include SpecControllerHelper
  with_routing_filter

  before :each do
    stub_scenario :forum_with_topics

    controller.instance_variable_set :@site, @site
  end

  describe "routing" do
    with_options :section_id => '1' do |r|
      r.maps_to_show '/'
      r.maps_to_show '/forum'
      r.maps_to_show '/de', :locale => 'de'
      r.maps_to_show '/de/forum', :locale => 'de'

      # r.maps_to_index '/tags/foo+bar', :tags => 'foo+bar'
      # r.maps_to_index '/de/tags/foo+bar', :locale => 'de', :tags => 'foo+bar'
      # r.maps_to_index '/forum/tags/foo+bar', :tags => 'foo+bar'
      # r.maps_to_index '/de/forum/tags/foo+bar', :locale => 'de', :tags => 'foo+bar'

      r.maps_to_show '/topics/a-topic', :id => 'a-topic'
      r.maps_to_show '/de/topics/a-topic', :locale => 'de', :id => 'a-topic'
      r.maps_to_show '/forum/topics/a-topic', :id => 'a-topic'
      r.maps_to_show '/de/forum/topics/a-topic', :locale => 'de', :id => 'a-topic'

      r.maps_to_show '/boards/1', :board_id => "1"
      r.maps_to_show '/de/boards/1', :locale => 'de', :board_id => "1"
      r.maps_to_show '/forum/boards/1', :board_id => "1"
      r.maps_to_show '/de/forum/boards/1', :locale => 'de', :board_id => "1"
    end

    # with_options :section_id => '1', :format => 'rss' do |r|
    #   r.maps_to_index '/forum.rss'
    #
    #   r.maps_to_index '/tags/foo+bar.rss', :tags => 'foo+bar'
    #   r.maps_to_index '/forum/tags/foo+bar.rss', :tags => 'foo+bar'
    #
    #   r.maps_to_show '/boards/1.rss', :board_id => "1"
    #   r.maps_to_show '/forum/boards/1.rss', :board_id => "1"
    #
    #   r.maps_to_show '/topics/a-topic.rss', :id => 'a-topic'
    #   r.maps_to_show '/forum/topics/a-topic.rss', :id => 'a-topic'
    #
    #   r.maps_to_index '/de.rss', :locale => 'de'
    #   r.maps_to_index '/de/forum.rss', :locale => 'de'
    #
    #   r.maps_to_index '/de/tags/foo+bar.rss', :tags => 'foo+bar', :locale => 'de'
    #   r.maps_to_index '/de/forum/tags/foo+bar.rss', :tags => 'foo+bar', :locale => 'de'
    #
    #   r.maps_to_show '/de/boards/1.rss', :board_id => "1", :locale => 'de'
    #   r.maps_to_show '/de/forum/boards/1.rss', :board_id => "1", :locale => 'de'
    #
    #   r.maps_to_show '/de/topics/a-topic.rss', :id => 'a-topic', :locale => 'de'
    #   r.maps_to_show '/de/forum/topics/a-topic.rss', :id => 'a-topic', :locale => 'de'
    # end
  end

  describe "the url_helper forum_path" do
    before :each do
      url_rewriter = ActionController::UrlRewriter.new @request, params_from(:get, '/de/forum')
      @controller.instance_variable_set :@url, url_rewriter
      @current_section = @forum
      @controller.stub!(:site).and_return @site
      @board = stub_board
    end

    @forum_path           = lambda { forum_path(@forum) }
    @tag_path             = lambda { forum_tag_path(@forum, 'foo+bar') }
    @board_path           = lambda { board_path(@forum, @board) }
    @topic_path           = lambda { topic_path(@forum, @topic.permalink) }

    # @formatted_forum_path = lambda { formatted_forum_path(@forum, :rss) }
    # @formatted_tag_path   = lambda { formatted_forum_tag_path(@forum, 'foo+bar', :rss) }
    # @formatted_board_path = lambda { formatted_board_path(@forum, @board, :rss) }
    # @formatted_topic_path = lambda { formatted_topic_path(@forum, @topic.permalink, :rss) }s

    rewrites_url @forum_path,               :to => '/',                               :on => [:default_locale, :root_section]
    rewrites_url @forum_path,               :to => '/forum',                           :on => [:default_locale]
    rewrites_url @forum_path,               :to => '/de',                             :on => [:root_section]
    rewrites_url @forum_path,               :to => '/de/forum'

    # rewrites_url @tag_path,                :to => '/tags/foo+bar',                   :on => [:default_locale, :root_section]
    # rewrites_url @tag_path,                :to => '/de/tags/foo+bar',                :on => [:root_section]
    # rewrites_url @tag_path,                :to => '/forum/tags/foo+bar',              :on => [:default_locale]
    # rewrites_url @tag_path,                :to => '/de/forum/tags/foo+bar'

    # # TODO fix this
    # rewrites_url @formatted_forum_path,     :to => '/forum.rss',                       :on => [:default_locale, :root_section]
    # rewrites_url @formatted_forum_path,     :to => '/de/forum.rss',                    :on => [:root_section]
    # rewrites_url @formatted_forum_path,     :to => '/forum.rss',                       :on => [:default_locale]
    # rewrites_url @formatted_forum_path,     :to => '/de/forum.rss'
    #
    # rewrites_url @formatted_tag_path,      :to => '/tags/foo+bar.rss',               :on => [:default_locale, :root_section]
    # rewrites_url @formatted_tag_path,      :to => '/de/tags/foo+bar.rss',            :on => [:root_section]
    # rewrites_url @formatted_tag_path,      :to => '/forum/tags/foo+bar.rss',          :on => [:default_locale]
    # rewrites_url @formatted_tag_path,      :to => '/de/forum/tags/foo+bar.rss'
    #
    # rewrites_url @formatted_category_path, :to => '/categories/foo.rss',             :on => [:default_locale, :root_section]
    # rewrites_url @formatted_category_path, :to => '/de/categories/foo.rss',          :on => [:root_section]
    # rewrites_url @formatted_category_path, :to => '/forum/categories/foo.rss',        :on => [:default_locale]
    # rewrites_url @formatted_category_path, :to => '/de/forum/categories/foo.rss'
    #
    # rewrites_url @forumpage_path,           :to => '/pages/a-forumpage',               :on => [:default_locale, :root_section]
    # rewrites_url @forumpage_path,           :to => '/de/pages/a-forumpage',            :on => [:root_section]
    # rewrites_url @forumpage_path,           :to => '/forum/pages/a-forumpage',          :on => [:default_locale]
    # rewrites_url @forumpage_path,           :to => '/de/forum/pages/a-forumpage'
    #
    # rewrites_url @formatted_forumpage_path,  :to => '/pages/a-forumpage.rss',          :on => [:default_locale, :root_section]
    # rewrites_url @formatted_forumpage_path,  :to => '/de/pages/a-forumpage.rss',       :on => [:root_section]
    # rewrites_url @formatted_forumpage_path,  :to => '/forum/pages/a-forumpage.rss',     :on => [:default_locale]
    # rewrites_url @formatted_forumpage_path,  :to => '/de/forum/pages/a-forumpage.rss'
  end
end