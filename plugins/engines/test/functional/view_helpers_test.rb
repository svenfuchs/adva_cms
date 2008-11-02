require File.dirname(__FILE__) + '/../test_helper'

class ViewHelpersTest < Test::Unit::TestCase
  def setup
    @controller = AssetsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    get :index
  end
  
  # TODO: refactor this to use assert_select  
  def test_plugin_javascript_helpers
    attrs = { :type => "text/javascript" }
    assert_tag :script, :attributes => attrs.update(:src => "/plugin_assets/test_assets/javascripts/file.1.js") 
    assert_tag :script, :attributes => attrs.update(:src => "/plugin_assets/test_assets/javascripts/file2.js")
  end

  def test_plugin_stylesheet_helpers
    attrs = { :media => "screen", :rel => "stylesheet", :type => "text/css" }
    assert_tag :link, :attributes => attrs.update(:href => "/plugin_assets/test_assets/stylesheets/file.1.css")
    assert_tag :link, :attributes => attrs.update(:href => "/plugin_assets/test_assets/stylesheets/file2.css")
  end

  def test_plugin_image_helpers
    assert_tag :img, :attributes => { :src => "/plugin_assets/test_assets/images/image.png", :alt => "Image" }
  end

  def test_plugin_layouts
    get :index
    assert_tag :div, :attributes => { :id => "assets_layout" }
  end  
end