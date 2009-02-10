require File.expand_path(File.dirname(__FILE__) + '/../../test_helper.rb')

class MessageTest < ActiveSupport::TestCase
  def setup
    super
    @message = Message.find_by_subject('a message to the moderator subject')
  end
  
  # Associations
  
  test "belongs to sender" do
    @message.should belong_to(:sender)
  end
  
  test "belongs to recipient" do
    @message.should belong_to(:recipient)
  end
  
  test "belongs to conversation" do
    @message.should belong_to(:conversation)
  end
  
  # Callbacks
  
  test "assigns message to a conversation before create" do
    Message.before_create.should include(:assign_to_conversation)
  end
  
  # Validations
  
  test "validates presence of subject" do
    @message.should validate_presence_of(:subject)
  end
  
  test "validates presence of body" do
    @message.should validate_presence_of(:body)
  end
  
  test "validates presence of recipient" do
    @message.should validate_presence_of(:recipient)
  end
  
  test "validates presence of sender" do
    @message.should validate_presence_of(:sender)
  end
  
  # Class methods
  
  test "#reply_to should return a new message object with the value recipient_id populated from message.sender_id" do
    @reply = Message.reply_to(@message)
    @reply.recipient_id.should == @message.sender_id
  end
  
  test "#reply_to should return a new message object with the value subject populated as 'Re: @message.subject'" do
    @reply = Message.reply_to(@message)
    @reply.subject.should == "Re: #{@message.subject}"
  end
  
  test "#reply_to should return a new message object with the value parent_id populated from message.id" do
    @reply = Message.reply_to(@message)
    @reply.parent_id.should == @message.id
  end
  
  # Instance methods
  
  test "#is_reply? returns false when message does not have a parent" do
    @message.is_reply?.should be_false
  end
  
  test "#is_reply? returns true when a message has a parent" do
    @message = Message.find_by_subject('Re: a message to the moderator subject')
    @message.is_reply?.should be_true
  end
  
  test "#mark_as_read marks the message as read" do
    @message.mark_as_read
    @message.read_at.should_not be_nil
  end
  
  test "#mark_as_deleted marks the message as deleted for sender when user is the sender of the message" do
    @message.mark_as_deleted(@message.sender)
    @message.deleted_at_sender.should_not be_nil
  end
  
  test "#mark_as_deleted does not mark the message as deleted for recipient when user is the sender of the message" do
    @message.mark_as_deleted(@message.sender)
    @message.deleted_at_recipient.should be_nil
  end
  
  test "#mark_as_deleted marks the message as deleted for recipient when user is the recipient of the message" do
    @message.mark_as_deleted(@message.recipient)
    @message.deleted_at_recipient.should_not be_nil
  end
  
  test "#mark_as_deleted does not mark the message as deleted for sender when user is the recipient of the message" do
    @message.mark_as_deleted(@message.recipient)
    @message.deleted_at_sender.should be_nil
  end
  
  test "#mark_as_deleted marks the message as deleted for sender when user is the sender and the recipient of the message" do
    @message = Message.find_by_subject('a message to self subject')
    @message.mark_as_deleted(@message.sender)
    @message.deleted_at_sender.should_not be_nil
  end
  
  test "#mark_as_deleted marks the message as deleted for recipient when user is the sender and the recipient of the message" do
    @message = Message.find_by_subject('a message to self subject')
    @message.mark_as_deleted(@message.sender)
    @message.deleted_at_recipient.should_not be_nil
  end
  
  test "#parent returns nil when message does not have a parent" do
    @message.parent.should be_nil
  end
  
  test "#parent returns the parent message when message has a parent" do
    @reply = Message.find_by_subject('Re: a message to the moderator subject')
    @reply.parent.should == @message
  end
  
  test "#reply_subject returns 'Re: message.subject'" do
    @message.reply_subject.should == "Re: #{@message.subject}"
  end
  
  test "#reply_subject returns 'Re: message.subject' also when message subject already has a Re: beginning" do
    @message = Message.find_by_subject('Re: a message to the moderator subject')
    @message.reply_subject.should == "#{@message.subject}"
  end
  
  test "#recipient? returns true when user is the recipient of the message" do
    @message.recipient?(@message.recipient).should be_true
  end
  
  test "#recipient? returns false when user is not the recipient of the message" do
    @message.recipient?(@message.sender).should be_false
  end
  
  test "#sender? returns true when user is the sender of the message" do
    @message.sender?(@message.sender).should be_true
  end
  
  test "#sender? returns false when user is not the sender of the message" do
    @message.sender?(@message.recipient).should be_false
  end
  
  # Protected methods
  
  test "#assign_to_conversation assigns a new conversation object when message does not have parent" do
    @message = Message.new
    mock(Conversation).create
    @message.send :assign_to_conversation
  end
  
  test "#assign_to_conversation assigns a parents conversation object to the message when message has parent" do
    @reply = Message.reply_to(@message)
    @reply.send :assign_to_conversation
    @reply.conversation.should == @message.conversation
  end
end