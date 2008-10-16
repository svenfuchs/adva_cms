require File.dirname(__FILE__) + '/../spec_helper'

class FooObserver; def handle_foo!(event) nil; end; end
class BarObserver; def handle_event!(event) nil; end; end

describe Event, '#add_observer' do
  it "takes observers" do
    lambda { Event.observers << mock('observer') }.should_not raise_error
  end
end

describe Event, '#trigger' do
  before :each do
    Event.observers << @foo_observer = FooObserver.new
    Event.observers << @bar_observer = BarObserver.new
    @event = mock('event', :type => :foo)
    Event.stub!(:new).and_return @event
  end

  it "instantiates a new Event" do
    Event.should_receive(:new).with(:foo, :object, :source, {}).and_return mock('event', :type => :foo)
    Event.trigger :foo, :object, :source
  end

  it "calls the handle_[event_type]! callback on each observer that implements it" do
    @foo_observer.should_receive(:handle_foo!).with @event
    Event.trigger :foo, :object, :source
  end

  it "calls the handle_event! callback on each observer that implements but does not implement handle_[event_type]!" do
    @bar_observer.should_receive(:handle_event!).with @event
    Event.trigger :foo, :object, :source
  end
end