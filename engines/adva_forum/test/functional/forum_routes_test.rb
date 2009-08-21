require File.expand_path(File.dirname(__FILE__) + '/../test_helper.rb')

class ForumRoutesTest < ActionController::TestCase
  tests ForumController

  with_common :default_routing_filters, :a_forum_without_boards

  paths = %W( /forums/1
              /forums/1/boards/1
              /forums/1/boards/1/topics/new
              /forums/1/topics
              /forums/1/topics/new
              /forums/1/topics/1
              /forums/1/topics/1/edit )

  paths.each do |path|
    test "regenerates the original path from the recognized params for #{path}" do
      without_routing_filters do
        params = ActionController::Routing::Routes.recognize_path(path, :method => :get)
        assert_equal path, @controller.url_for(params.merge(:only_path => true))
      end
    end
  end

  describe "routing" do
    forum_id = Forum.first.id.to_s

    with_options :section_id => forum_id do |r|
      r.it_maps :get, '/',                                   :action => 'show'
      r.it_maps :get, '/a-forum-without-boards',             :action => 'show'
      r.it_maps :get, '/boards/1',                           :action => 'show', :board_id => "1"
      r.it_maps :get, '/a-forum-without-boards/boards/1',    :action => 'show', :board_id => "1"

      r.it_maps :get, '/de',                                 :action => 'show',                   :locale => 'de'
      r.it_maps :get, '/de/a-forum-without-boards',          :action => 'show',                   :locale => 'de'
      r.it_maps :get, '/de/boards/1',                        :action => 'show', :board_id => "1", :locale => 'de'
      r.it_maps :get, '/de/a-forum-without-boards/boards/1', :action => 'show', :board_id => "1", :locale => 'de'

      # r.it_maps :get, '/tags/foo+bar',                           :tags => 'foo+bar'
      # r.it_maps :get, '/de/tags/foo+bar',                        :tags => 'foo+bar', :locale => 'de'
      # r.it_maps :get, '/a-forum-without-boards/tags/foo+bar',    :tags => 'foo+bar'
      # r.it_maps :get, '/de/a-forum-without-boards/tags/foo+bar', :tags => 'foo+bar', :locale => 'de'
    end

    with_options :controller => 'topics', :section_id => forum_id do |r|
      r.it_maps :get, '/topics/a-topic',         :action => 'show', :id => 'a-topic'
      r.it_maps :get, '/de/topics/a-topic',      :action => 'show', :id => 'a-topic', :locale => 'de'
      r.it_maps :get, '/de/topics/a-topic/edit', :action => 'edit', :id => 'a-topic', :locale => 'de'
    end

    with_options :controller => 'posts', :section_id => forum_id do |r|
      r.it_maps :get, '/de/topics/1/posts/1/edit', :action => 'edit', :topic_id => '1', :id => '1', :locale => 'de'
    end
    
    with_options :controller => 'topics', :section_id => forum_id, :format => 'rss' do |r|
      r.it_maps :get, '/topics/a-topic.rss',    :action => 'show', :id => 'a-topic'
      r.it_maps :get, '/de/topics/a-topic.rss', :action => 'show', :id => 'a-topic', :locale => 'de'
    end
    
    # with_options :section_id => forum_id, :format => 'rss' do |r|
    #   r.it_maps :get, '/a-forum-without-boards.rss'
    #   r.it_maps :get, '/tags/foo+bar.rss',                             :tags => 'foo+bar'
    #   r.it_maps :get, '/a-forum-without-boards/tags/foo+bar.rss',      :tags => 'foo+bar'
    #   r.it_maps :get, '/boards/1.rss',                                 :board_id => "1"
    #   r.it_maps :get, '/a-forum-without-boards/boards/1.rss',          :board_id => "1"
    #   r.it_maps :get, '/a-forum-without-boards/topics/a-topic.rss',    :id => 'a-topic'
    #   r.it_maps :get, '/de.rss',                                       :locale => 'de'
    #   r.it_maps :get, '/de/a-forum-without-boards.rss',                :locale => 'de'
    #   r.it_maps :get, '/de/tags/foo+bar.rss',                          :tags => 'foo+bar', :locale => 'de'
    #   r.it_maps :get, '/de/a-forum-without-boards/tags/foo+bar.rss',   :tags => 'foo+bar', :locale => 'de'
    #   r.it_maps :get, '/de/boards/1.rss',                              :board_id => "1", :locale => 'de'
    #   r.it_maps :get, '/de/a-forum-without-boards/boards/1.rss',       :board_id => "1", :locale => 'de'
    #   r.it_maps :get, '/de/a-forum-without-boards/topics/a-topic.rss', :id => 'a-topic', :locale => 'de'
    # end
  end
end
