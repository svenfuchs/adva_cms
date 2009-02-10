require File.dirname(__FILE__) + '/helper'

class ContextCompileTest < Test::Unit::TestCase
  def setup
    Target.reset
    With.shared.clear
  end
  
  def call(context)
    context.compile(Target)
    target = Target.new

    target.methods.select{|m| m =~ /^test/ }.sort.reverse.inject([]) do |called, method| 
      target.send(method)
      called << target.called.dup
      target.called.clear
      called
    end
  end
  
  def test_compile_simple
    collector = lambda { (@called ||= []) << @_with_current_context }
  
    context = With::Context.build('foo') do 
      before 'before_1', &collector
      before 'before_2', &collector
      action 'action',   &collector
      assertion 'assertion_1', &collector
      assertion 'assertion_2', &collector
      after 'after_1', &collector
      after 'after_2', &collector
    end.first
    
    expected = [['before_1', 'before_2', 'action', 'assertion_1', 'assertion_2', 'after_1', 'after_2']]
    assert_equal expected, call(context)
  end
  
  def test_compile
    collector = lambda { (@called ||= []) << @_with_current_context }
  
    With.share :shared, 'shared_1' do
      before 'shared_1_before', &collector
      assertion 'shared_1_assertion', &collector
      after 'shared_1_after', &collector
    end
  
    With.share :shared, 'shared_2' do
      before 'shared_2_before', &collector
      assertion 'shared_2_assertion', &collector
      after 'shared_2_after', &collector
    end
    
    context = With::Context.build('foo', :shared) do
      before 'foo_before', &collector
      action 'foo_action', &collector
      assertion 'foo_assertion', &collector
      after 'foo_after', &collector
      
      with ['bar', 'baz'] do
        before "#{name}_before", &collector
        assertion "#{name}_assertion", &collector
        after "#{name}_after", &collector
      end
    end.first
    
    expected = [['shared_1_before', 'foo_before', 'bar_before', 
                 'foo_action', 
                 'shared_1_assertion', 'foo_assertion', 'bar_assertion',
                 'shared_1_after', 'foo_after', 'bar_after'],
                ['shared_1_before', 'foo_before', 'baz_before', 
                 'foo_action', 
                 'shared_1_assertion', 'foo_assertion', 'baz_assertion',
                 'shared_1_after', 'foo_after', 'baz_after'],
                ['shared_2_before', 'foo_before', 'bar_before', 
                 'foo_action', 
                 'shared_2_assertion', 'foo_assertion', 'bar_assertion',
                 'shared_2_after', 'foo_after', 'bar_after'],
                ['shared_2_before', 'foo_before', 'baz_before', 
                 'foo_action', 
                 'shared_2_assertion', 'foo_assertion', 'baz_assertion',
                 'shared_2_after', 'foo_after', 'baz_after']]
    assert_equal expected, call(context)
  end
  
  def test_compile_with_conditions
    collector = lambda { (@called ||= []) << @_with_current_context }
  
    With.share(:shared, 'shared_1') { before 'shared_1_before', &collector }
    With.share(:shared, 'shared_2') { before 'shared_2_before', &collector }
    
    context = With::Context.build('foo', :shared) do
      before 'foo_before_1', :in => 'shared_1', &collector
      before 'foo_before_2', :in => 'shared_2', &collector
      after 'foo_after_1', :not_in => 'shared_1', &collector
      after 'foo_after_2', :not_in => 'foo', &collector
      with('bar', :in => 'shared_1') do
        before 'bar_before', &collector
      end
    end.first
    
    expected = [['shared_2_before', 'foo_before_2', 'foo_after_1'],
                ['shared_1_before', 'foo_before_1', 'bar_before']]
    
    assert_equal expected, call(context)
  end
end