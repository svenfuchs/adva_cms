require File.expand_path(File.dirname(__FILE__) + "/../test_helper")

class ForumRoutesTest < ActionController::TestCase
  tests ForumController
  
  paths = %W( /forums/1
              /forums/1/boards/1
              /forums/1/boards/1/topics/new
              /forums/1/topics
              /forums/1/topics/1
              /forums/1/topics/new )

  paths.each do |path|
    test "regenerates the original path from the recognized params for #{path}" do
      without_routing_filters do
        params = ActionController::Routing::Routes.recognize_path(path, :method => :get)
        assert_equal path, @controller.url_for(params.merge(:only_path => true))
      end
    end
  end
end