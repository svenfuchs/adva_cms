require File.dirname(__FILE__) + "/../spec_helper"

describe UserMailer do
  it "observes events" do
    Event.observers.include?(UserMailer).should be_true
  end
  
  it "implements #handle_user_registered!" do
    UserMailer.should respond_to(:handle_user_registered!)
  end
  
  it "receives #handle_user_registered! when a :user_registered event is triggered" do
    event = mock('event', :type => :user_registered)
    Event.stub!(:new).and_return event
    UserMailer.should_receive(:handle_user_registered!).with(event)
    Event.trigger :user_registered, mock('user'), mock('controller')
  end
end
