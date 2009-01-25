require File.dirname(__FILE__) + '/helper'

class ViewTest < Test::Unit::TestCase
  def setup
    With.views.clear
  end
  
  def test_registers_views_as_call
    With.view(:foo) {}
    assert_equal :foo, With.view(:foo).name
  end
end