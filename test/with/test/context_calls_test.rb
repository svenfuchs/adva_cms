require File.dirname(__FILE__) + '/helper'

class ContextCallsTest < Test::Unit::TestCase
  def teardown
    With.shared.clear
  end 

  def test_registers_before
    context = With::Context.build('foo'){ before('before'){ }}.first
    assert_equal 'before', context.calls(:before).first.name
  end
  
  def test_registers_action
    context = With::Context.build('foo'){ action('action'){ }}.first
    assert_equal 'action', context.calls(:action).first.name
  end
  
  def test_registers_assertion
    context = With::Context.build('foo'){ assertion('assertion'){ }}.first
    assert_equal 'assertion', context.calls(:assertion).first.name
  end
  
  def test_registers_after
    context = With::Context.build('foo'){ after('after'){ }}.first
    assert_equal 'after', context.calls(:after).first.name
  end
  
  def test_registers_missing_method_calls_as_assertions
    context = With::Context.build('foo'){ assert(true) }.first
    assert_equal 'assert_true', context.calls(:assertion).first.name
  end
  
  def test_wraps_explicit_call_into_shared_context
    With.share(:bar){ }
    contexts = With::Context.build('foo'){ assertion('assertion', :with => :bar){ }}
    assert_equal [[['foo', :bar]]], context_names(contexts)
  end
  
  def test_wraps_missing_method_call_into_shared_context
    With.share(:bar){ }
    contexts = With::Context.build('foo'){ assert(true, :with => :bar){ }}
    assert_equal [[['foo', :bar]]], context_names(contexts)
  end
  
  def test_registers_explicit_call_with_in_condition
    context = With::Context.build('foo'){ before('before', :in => 'foo'){ }}.first
    assert_equal 'foo', context.calls(:before).first.instance_variable_get(:@conditions)[:in]
    assert context.calls(:before).first.applies?(context)
  end
  
  def test_registers_missing_method_call_with_in_condition
    context = With::Context.build('foo'){ assert(true, :in => 'foo'){ }}.first
    assert_equal 'foo', context.calls(:assertion).first.instance_variable_get(:@conditions)[:in]
    assert context.calls(:assertion).first.applies?(context)
  end
end