require File.dirname(__FILE__) + '/test_helper'

class ActionControllerTest < Test::Unit::TestCase
  ::ActionController::Routing::Routes.draw do |map|
    map.connect "/:controller/:action/:id"
  end

  def setup
    @controller = HelloWorldController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_rendering_component_from_controller
    get :say_it, :string => "onomatopoeia"
    assert_equal "onomatopoeia", @response.body
  end

  def test_standard_component_options
    HelloWorldController.any_instance.stubs(:standard_component_options).returns(:user => "snuffalumpagus")
    HelloWorldComponent.any_instance.expects(:say_it).with("wawoowifnik", :user => "snuffalumpagus")
    get :say_it, :string => "wawoowifnik"
  end
end