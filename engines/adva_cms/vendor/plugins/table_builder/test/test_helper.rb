$: << File.dirname(__FILE__) + "/../lib"

require 'rubygems'
require 'activesupport'
require 'actionpack'
require 'action_controller'
require 'action_view'
require 'action_view/test_case'
require 'table_builder'

class Test::Unit::TestCase
  include ActionController::Assertions::SelectorAssertions

  def assert_html(html, *args, &block)
    assert_select(HTML::Document.new(html).root, *args, &block)
  end
end

