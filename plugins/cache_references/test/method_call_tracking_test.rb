$:.unshift File.expand_path(File.dirname(__FILE__) + '/../lib')

require 'rubygems'
require 'mocha'
require 'cache_references/method_call_tracking'

class MethodCallTrackerTest < Test::Unit::TestCase
  include CacheReferences

  def setup
    @controller = mock('controller')
    @tracker = MethodCallTracking::MethodCallTracker.new
  end

  def test_resolve_trackable_resolves_ivars_and_method_names_given_as_symbols_or_strings
    @controller.expects(:instance_variable_get).with(:@foo)
    @tracker.send(:resolve_trackable, @controller, :@foo)

    @controller.expects(:instance_variable_get).with(:@foo)
    @tracker.send(:resolve_trackable, @controller, '@foo')

    @controller.expects(:foo)
    @tracker.send(:resolve_trackable, @controller, :foo)

    @controller.expects(:foo)
    @tracker.send(:resolve_trackable, @controller, 'foo')
  end

  def test_initialize_resolves_trackables_given_as_symbol_string_or_hash_key
    @controller.expects(:instance_variable_get).with(:@foo)
    @controller.expects(:bar)
    @controller.expects(:baz)

    @tracker.track @controller, :@foo, :bar, { :baz => nil }
  end

  def test_tracks_read_attribute_method_when_given_method_is_an_attribute
    foo = stub('foo', :has_attribute? => true)
    @controller.expects(:foo).returns foo
  
    foo.expects(:track_method_calls).with([])
    @tracker.track @controller, :foo
  end

  def test_tracks_method_when_given_method_is_not_an_attribute
    foo = stub('foo', :has_attribute? => false)
    @controller.expects(:foo).returns foo

    foo.expects(:track_method_calls).with([], :bar)
    @tracker.track @controller, :foo => :bar
  end
end

class MethodReadTrackingTest < Test::Unit::TestCase
  class Record
    include CacheReferences::MethodCallTracking

    def title; end
    def foo(bar, baz); end
  end

  def setup
    @record = Record.new
    @references = []
  end

  def test_installs_on_methods_without_arguments
    assert_nothing_raised {
      @record.track_method_calls(@references, :title)
      @record.title
    }
  end

  def test_installs_on_methods_with_arguments
    assert_nothing_raised {
      @record.track_method_calls(@references, :foo)
      @record.foo(:bar, :baz)
    }
  end

  def test_installs_method_on_metaclass
    @record.track_method_calls(@references, :title)
    assert (class << @record; self; end).method_defined?(:title)
  end

  def test_adds_method_call_reference_to_given_references_array
    @record.track_method_calls(@references, :title)
    @record.title
    assert_equal [@record, :title], @references.first
  end

  def test_does_not_add_multiple_references_on_subsequent_calls
    @record.track_method_calls(@references, :title)
    @record.title
    @record.title
    assert_equal [@record, :title], @references.first
  end

  def test_allows_to_setup_tracking_multiple_times_for_the_same_method
    assert_nothing_raised {
      @record.track_method_calls(@references, :title)
      @record.track_method_calls(@references, :title)
    }
    @record.title
    @record.title
    assert_equal [@record, :title], @references.first
  end
end
