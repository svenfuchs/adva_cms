require File.expand_path(File.dirname(__FILE__) + "/../../test_helper")

class UserMailerTest < ActiveSupport::TestCase
  test "observes events" do
    Event.observers.should include('UserMailer')
  end

  test "implements #handle_user_registered!" do
    UserMailer.should respond_to(:handle_user_registered!)
  end

  test "receives #handle_user_registered! when a :user_registered event is triggered" do
    mock(UserMailer).handle_user_registered!.with(anything)
    Event.trigger(:user_registered, User.new, self)
  end
end
