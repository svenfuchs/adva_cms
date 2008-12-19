require File.dirname(__FILE__) + '/test_helper'

class ComponentsTest < Test::Unit::TestCase
  def test_component_response
    HelloWorldComponent.any_instance.expects(:say_it).returns("mukadoogle")
    assert_equal "mukadoogle", Components.render("hello_world/say_it", ["gigglemuppit"])
  end

  def test_rendering_a_component_view
    assert_equal "<b>pifferspangle</b>", Components.render("hello_world/say_it_with_style", ["pifferspangle"])
  end

  def test_implied_render_file
    assert_equal "<b>foofididdums</b>", Components.render("hello_world/bolded", ["foofididdums"])
  end

  def test_inherited_views
    assert_equal "parent/one", Components.render("parent/one")
    assert_equal "parent/two", Components.render("parent/two")
    assert_equal "child/one",  Components.render("child/one")
    assert_equal "parent/two", Components.render("child/two")
  end

  def test_links_in_views
    rendered = Components.render("rich_view/linker", ["http://example.com"])
    assert_select rendered, "a[href=http://example.com]"
  end

  def test_form_in_views
    ActionController::Base.request_forgery_protection_token = :authenticity_token
    rendered = Components.render("rich_view/form", [], :form_authenticity_token => "bluetlecrashit")
    assert_select rendered, "form"
    assert_select rendered, "input[type=hidden][name=authenticity_token][value=bluetlecrashit]"
  end

  def test_url_for_in_views
    assert_nothing_raised do
      ActionController::Routing::RouteSet.any_instance.stubs(:generate).returns("some_url")
      Components.render("rich_view/urler")
    end
  end

  def test_helper_methods
    assert_equal "jingleheimer", Components.render("hello_world/say_it_with_help", ["jingleheimer"])
  end

  protected

  def assert_select(content, *args)
    super(HTML::Document.new(content).root, *args)
  end
end
