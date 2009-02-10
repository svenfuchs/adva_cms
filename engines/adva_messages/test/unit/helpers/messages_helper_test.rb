require File.expand_path(File.dirname(__FILE__) + '/../../test_helper.rb')

class MessagesHelperTest < ActiveSupport::TestCase
  include MessagesHelper
  
  def setup
    super
    @site = Site.find_by_host('site-with-sections.com')
    @message = Message.find_by_subject('a message to the moderator subject')
  end
  
  test "#recipients_list should return a sorted array of site users" do
    site_users = @site.users.collect {|u| [u.name, u.id] }.sort
    recipients_list(@site).should == site_users
  end
  
  test "#message_type returns 'message_sender' when user is the sender of the message" do
    stub(self).current_user.returns(@message.sender)
    message_type(@message).should == 'message_sender'
  end
  
  test "#message_type returns 'message_recipient' when user is the recipient of the message" do
    stub(self).current_user.returns(@message.recipient)
    message_type(@message).should == 'message_recipient'
  end
end