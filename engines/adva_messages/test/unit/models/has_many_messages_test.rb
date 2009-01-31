require File.expand_path(File.dirname(__FILE__) + '/../../test_helper.rb')

class HasManyMessagesTest < ActiveSupport::TestCase
  
  def setup
    super
    @user             = User.find_by_email('a-user@example.com')
    @message_sent     = @user.messages_sent.first
    @message_received = @user.messages_received.first
  end
  
  # Associations
    
  test "has many received messages" do
    @user.should have_many(:messages_received)
  end

  test "has many sent messages" do
    @user.should have_many(:messages_sent)
  end
  
  test "has many conversations" do
    @user.should have_many(:conversations)
  end
  
  # Public methods
  
  # FIXME add test for conversations too
  
  test "#messages_received returns only messages where user is recipient" do
    @user.messages_received.should == [@message_received]
  end
  
  test "#messages_received does not return messages where user is recipient if they are deleted" do
    @message_received.mark_as_deleted(@user)
    @user.messages_received.should_not == [@message_received]
  end
  
  test "#messages_sent returns only messages where user is sender" do
    @user.messages_sent.should == [@message_sent]
  end
  
  test "#messages_sent does not return messages where user is sender if they are deleted" do
    @message_sent.mark_as_deleted(@user)
    @user.messages_sent.should_not == [@message_sent]
  end
  
  test "#messages returns sent and received messages of the user" do
    @user.messages.should == [@message_received, @message_sent]
  end
end