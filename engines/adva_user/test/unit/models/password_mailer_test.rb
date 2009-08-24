require File.expand_path(File.dirname(__FILE__) + "/../../test_helper")

class PasswordMailerTest < ActiveSupport::TestCase

  test "observes events" do
    Event.observers.should include('PasswordMailer')
  end

  test "implements #handle_user_password_reset_requested!" do
    PasswordMailer.should respond_to(:handle_user_password_reset_requested!)
  end

  test "implements #handle_user_password_updated!" do
    PasswordMailer.should respond_to(:handle_user_password_updated!)
  end

  test "receives #handle_user_password_reset_requested! when a :user_password_reset_requested event is triggered" do
    mock(PasswordMailer).handle_user_password_reset_requested!.with(anything)
    Event.trigger(:user_password_reset_requested, User.new, self)
  end

  test "receives #handle_user_password_updated! when a :user_password_updated event is triggered" do
    mock(PasswordMailer).handle_user_password_updated!.with(anything)
    Event.trigger(:user_password_updated, User.new, self)
  end
end