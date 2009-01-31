require File.expand_path(File.dirname(__FILE__) + "/../test_helper")

class CommentsRoutesTest < ActionController::TestCase
  tests CommentsController
  
  paths = %W( /comments
              /comments/1 )

  paths.each do |path|
    test "regenerates the original path from the recognized params for #{path}" do
      without_routing_filters do
        params = ActionController::Routing::Routes.recognize_path(path, :method => :get)
        assert_equal path, @controller.url_for(params.merge(:only_path => true))
      end
    end
  end
end