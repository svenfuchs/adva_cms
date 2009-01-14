$:.unshift File.expand_path(File.dirname(__FILE__) + '/../lib')

require 'rubygems'
require 'mocha'

require 'page_cache_tagging/attributes_read_observer'
require 'page_cache_tagging/method_read_observer'
require 'page_cache_tagging/read_access_tracker'

class ReadAccessTrackerTest < Test::Unit::TestCase
  include PageCacheTagging
  
  def setup
    @controller = mock('controller')
  end
  
  def test_resolve_trackable_resolves_ivars_and_method_names_given_as_symbols_or_strings
    tracker = ReadAccessTracker.new @controller

    @controller.expects(:instance_variable_get).with(:@foo)
    tracker.send(:resolve_trackable, @controller, :@foo)

    @controller.expects(:instance_variable_get).with(:@foo)
    tracker.send(:resolve_trackable, @controller, '@foo')

    @controller.expects(:foo)
    tracker.send(:resolve_trackable, @controller, :foo)

    @controller.expects(:foo)
    tracker.send(:resolve_trackable, @controller, 'foo')
  end
  
  def test_initialize_resolves_trackables_given_as_symbol_string_or_hash_key
    @controller.expects(:instance_variable_get).with(:@foo)
    @controller.expects(:bar)
    @controller.expects(:baz)

    ReadAccessTracker.new @controller, :@foo, :bar, { :baz => nil }
  end
  
  def test_wraps_trackable_into_an_attribute_read_observer_when_it_is_an_attribute
    foo = stub('foo', :has_attribute? => true)
    observer = stub('observer', :register => nil)
    @controller.expects(:foo).returns foo
    
    AttributesReadObserver.expects(:new).with(foo, nil).returns(observer)
    ReadAccessTracker.new @controller, :foo
  end
  
  def test_wraps_trackable_into_a_method_read_observer_when_the_given_method_is_not_an_attribute
    foo = stub('foo', :has_attribute? => false)
    observer = stub('observer', :register => nil)
    @controller.expects(:foo).returns foo
    
    MethodReadObserver.expects(:new).with(foo, [:bar]).returns(observer)
    ReadAccessTracker.new @controller, :foo => :bar
  end
end