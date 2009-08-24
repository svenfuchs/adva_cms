require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class FooObserver; def handle_foo!(event) nil; end; end
class BarObserver; def handle_event!(event) nil; end; end

class EventTest < ActiveSupport::TestCase
  def setup
    super
    @old_observers = Event.observers.clone
    Event.observers.clear
    Event.observers << @foo_observer = FooObserver.new
    Event.observers << @bar_observer = BarObserver.new
    @event = Event.new(:foo, nil, nil)
    stub(Event).new(:foo, :object, :source, {}).returns(@event)
  end

  def teardown
    super
    Event.observers = @old_observers
  end

  test '#add_observer takes observers' do
    lambda { Event.observers << mock('observer') }.should_not raise_error
  end

  test "#trigger instantiates a new Event" do
    mock(Event).new(:foo, :object, :source, {}).returns(@event)
    Event.trigger(:foo, :object, :source)
  end

  test "#trigger calls the handle_[event_type]! callback on each observer that implements it" do
    mock(@foo_observer).handle_foo!(@event)
    Event.trigger(:foo, :object, :source)
  end

  test "#trigger calls the handle_event! callback on each observer that implements but does not implement handle_[event_type]!" do
    mock(@bar_observer).handle_event!(@event)
    Event.trigger(:foo, :object, :source)
  end
end

