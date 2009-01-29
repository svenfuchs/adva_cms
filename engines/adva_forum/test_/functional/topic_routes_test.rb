require File.expand_path(File.dirname(__FILE__) + '/../test_helper.rb')

class TopicRoutesTest < ActionController::TestCase
  tests TopicsController
  
  with_common :a_forum_without_boards
  
  describe "routing" do
    forum = Forum.first
    topic = forum.topics.first
    
    with_options :section_id => "#{forum.id}" do |r|
      r.it_maps :get, '/topics/a-topic',                            :action => 'show', :id => 'a-topic'
      r.it_maps :get, '/de/topics/a-topic',                         :action => 'show', :locale => 'de', :id => 'a-topic'
      
      # r.it_maps :get, '/a-forum-without-boards/topics/a-topic',                     #  :id => 'a-topic'
      # r.it_maps :get, '/de/a-forum-without-boards/topics/a-topic',  :locale => 'de'#,  :id => 'a-topic'
    end

    with_options :section_id => "#{forum.id}", :format => 'rss' do |r|
      r.it_maps :get, '/topics/a-topic.rss',    :action => 'show', :id => 'a-topic'
      r.it_maps :get, '/de/topics/a-topic.rss', :action => 'show', :id => 'a-topic', :locale => 'de'
      
      # r.it_maps :get, '/de/forum/topics/a-topic.rss', :action => 'show', :id => 'a-topic', :locale => 'de'
    end
  end
end