require File.dirname(__FILE__) + '/helper'

class ContextStructureTest < Test::Unit::TestCase
  def teardown
    With.shared.clear
  end 
  
  # generates 1 context, nested 3 levels deep
  def test_nested_context
    names = context_names With::Context.build('foo'){ with('bar') { with('baz') }}
    assert_equal [[['foo', 'bar', 'baz']]], names
  end
  
  # generates 2 contexts, nested 3 levels deep and alternates the 2. level
  def test_and_or_and
    names = context_names With::Context.build('foo', ['bar', 'baz'], 'buz')
    assert_equal [[['foo', 'bar', 'buz'], ['foo', 'baz', 'buz']]], names
  end
  
  # same, but additionally nests 2 more levels
  def test_and_or_and_with_nested_context
    names = context_names With::Context.build('foo', ['bar', 'baz'], 'buz') { with('boz') { with('bum') } }
    assert_equal [[['foo', 'bar', 'buz', 'boz', 'bum'], ['foo', 'baz', 'buz', 'boz', 'bum']]], names
  end
  
  # generates 2 contexts, nested 3 levels deep and alternates the 1. level
  def test_or_and_and
    names = context_names With::Context.build(['foo', 'bar'], 'baz', 'buz')
    assert_equal [[['foo', 'baz', 'buz']], [['bar', 'baz', 'buz']]], names
  end
  
  # same, but additionally nests 2 more levels
  def test_or_and_and_with_nested_context
    names = context_names With::Context.build(['foo', 'bar'], 'baz', 'buz') { with('boz'){ with('bum') } }
    assert_equal [[['foo', 'baz', 'buz', 'boz', 'bum']], [['bar', 'baz', 'buz', 'boz', 'bum']]], names
  end
  
  # generates 3 contexts, nested 3 levels deep and alternates the 1. level
  def test_or_and_and_with_shared_context
    With.share(:foo, 'foo-1')
    With.share(:foo, 'foo-2')
    names = context_names With::Context.build([:foo, 'bar'], 'baz', 'buz')
    assert_equal [[['foo-1', 'baz', 'buz']], [['foo-2', 'baz', 'buz']], [['bar', 'baz', 'buz']]], names
  end
  
  def test_shared_context_with_nesting
    With.share(:foo, 'foo-1') { with('bar') { with('baz') } }
    With.share(:foo, 'foo-2')
    names = context_names With::Context.build(:foo, 'buz')
    assert_equal [[['foo-1', 'bar', 'baz', 'buz']], [['foo-2', 'buz']]], names
  end
  
  def test_and_with_shared_context
    With.share(:foo, 'foo-1') { with('bar') { with('baz') } }
    With.share(:foo, 'foo-2')
    names = context_names With::Context.build('fam', :foo)
    assert_equal [[['fam', 'foo-1', 'bar', 'baz'], ['fam', 'foo-2']]], names
  end
  
  def test_and_or_with_shared_context
    With.share(:foo, 'foo-1') { with('bar') { with('baz') } }
    With.share(:foo, 'foo-2')
    names = context_names With::Context.build('fam', [:foo, 'fum'])
    assert_equal [[['fam', 'foo-1', 'bar', 'baz'], 
                   ['fam', 'foo-2'], 
                   ['fam', 'fum']]], names
  end
  
  def test_or_and_and_with_shared_context_with_nesting_and_with_nested_context
    With.share(:foo, 'foo-1') { with('bar') { with('baz') } }
    With.share(:foo, 'foo-2')
    names = context_names With::Context.build('fam', [:foo, 'fum'], 'buz') { with('boz') { with('bum') } }
    assert_equal [[['fam', 'foo-1', 'bar', 'baz', 'buz', 'boz', 'bum'],
                   ['fam', 'foo-2', 'buz', 'boz', 'bum'], 
                   ['fam', 'fum',   'buz', 'boz', 'bum']]], names
  end
  
  def test_shared_contexts_are_duplicated_so_they_can_be_reused
    With.share(:foo, 'foo') { with('bar') }
    With::Context.build('fam', :foo) { with('bum!') }
    names = context_names With::Context.build(:foo) { with('baz') }
    assert !names.flatten.include?('bum!'), "expected #{names.inspect} not to include 'bum!'"
  end
  
  def test_context_with_in_condition_applies
    context = With::Context.build('bar'){ with('foo', :in => 'bar') }.first 
    assert_equal 'foo', context.children.first.name
  end
  
  def test_context_with_in_condition_does_not_apply
    context = With::Context.build('bar'){ with('foo', :in => 'baz') }.first 
    assert context.children.empty?
  end
  
  def test_context_with_not_in_condition_applies
    context = With::Context.build('bar'){ with('foo', :not_in => 'bar') }.first 
    assert context.children.empty?
  end
  
  def test_context_with_not_in_condition_does_not_apply
    context = With::Context.build('bar'){ with('foo', :not_in => 'baz') }.first 
    assert_equal 'foo', context.children.first.name
  end
  
  def test_context_with_common_parents
    Target.with_common :common
    Target.share(:common){}
    names = context_names [Target.describe('bar'){ with 'foo' }]
    assert_equal [[['bar', :common, 'foo']]], names
  end
  
  def test_different_nested_contexts_with_common_shared_parent
    With.share(:bar, 'bar') {  }
    context = With::Context.build('foo') do 
      with(:bar){ assertion('renders :new'){} } 
      with(:bar){ assertion('renders :edit'){} } 
    end.first
    assert_equal 'renders :new', context.children[0].calls(:assertion)[0].name
    assert_equal 'renders :edit', context.children[1].calls(:assertion)[0].name
  end
  
  def test_node_knows_its_filename_and_linenumber
    context = With::Context.build('foo'){ }.first
    assert_equal __FILE__, context.send(:file)
    assert_equal __LINE__ - 2, context.send(:line)
  end
  
  def test_select_finds_nodes_with_a_block_matching
    context = With::Context.build('foo'){ 
      with('bar'){}
    }.first.select { |block| block.send(:line) == __LINE__ - 1 }.first
    assert_equal 'bar', context.name
  end
  
  def test_implemented_at_returns_true_when_context_or_call_is_implemented_at_given_file_and_line
    context = With::Context.build('foo'){ 
      with('bar'){}
    }.first
    assert context.implemented_at?(:file => __FILE__, :line => __LINE__ - 3)
    assert context.children.first.implemented_at?(:file => __FILE__, :line => __LINE__ - 3)
  end
end