module MessagesHelper
  def recipients_list(site)
    site.users.collect {|u| [u.name, u.id]}.sort
  end
  
  def message_type(message)
    message.sender?(current_user) ? 'message_sender' : 'message_recipient'
  end
end