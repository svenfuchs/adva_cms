class Test::Unit::TestCase
  share :log_in_as_user_with_message do
    before do
      @user    = User.find_by_email('a-user@example.com')
      @message = @user.messages_sent.first
      login @user
    end
  end
  
  share :superusers_message do
    before do
      @superuser = User.find_by_email('a-superuser@example.com')
      @superuser_message = @superuser.messages.first
    end
  end
end