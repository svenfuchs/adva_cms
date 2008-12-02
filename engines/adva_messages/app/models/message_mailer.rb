class MessageMailer < ActionMailer::Base
  include Login::MailConfig

  class << self
    def handle_message_created!(event)
      deliver_message_created_email event.object, event.source
    end
  end
  
  def message_created_email(message, source)
    recipient   = message.recipient
    recipients  recipient.email
    from        system_email(source.request.url)
    subject     "You have received a new message!"
    body        :message => message
  end
end