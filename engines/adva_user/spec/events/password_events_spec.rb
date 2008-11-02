require File.dirname(__FILE__) + "/../spec_helper"

describe PasswordMailer do
  it "observes events" do
    Event.observers.include?(PasswordMailer).should be_true
  end
    
  it "implements #handle_user_password_reset_requested!" do
    PasswordMailer.should respond_to(:handle_user_password_reset_requested!)
  end
    
  it "implements #handle_user_password_updated!" do
    PasswordMailer.should respond_to(:handle_user_password_updated!)
  end
  
  it "receives #handle_user_password_reset_requested! when a :user_password_reset_requested event is triggered" do
    event = mock('event', :type => :user_password_reset_requested)
    Event.stub!(:new).and_return event
    PasswordMailer.should_receive(:handle_user_password_reset_requested!).with(event)
    Event.trigger :password_reset_requested, mock('user'), mock('controller')
  end
  
  it "receives #handle_user_password_updated! when a :user_password_updated event is triggered" do
    event = mock('event', :type => :user_password_updated)
    Event.stub!(:new).and_return event
    PasswordMailer.should_receive(:handle_user_password_updated!).with(event)
    Event.trigger :password_updated, mock('user'), mock('controller')
  end
end