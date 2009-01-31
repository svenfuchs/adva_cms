require File.expand_path(File.dirname(__FILE__) + '/../../test_helper.rb')

class ConversationTest < ActiveSupport::TestCase
  def setup
    super
    @conversation = Conversation.first
  end
  
  test "has many messages" do
    @conversation.should have_many(:messages)
  end
  
  test "#mark_messages_as_read marks messages as read" do
    @conversation.mark_messages_as_read
    @conversation.messages.each do |message|
      message.read_at.should_not be_nil
    end
  end
end