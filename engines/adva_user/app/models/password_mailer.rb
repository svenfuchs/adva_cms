class PasswordMailer < ActionMailer::Base
  include Login::MailConfig

  class << self
    def handle_user_password_reset_requested!(event)
      deliver_reset_password_email(
        :user => event.object, 
        :from => site(event.source.site).email_from,
        :reset_link => password_reset_link(event.source, event.token), 
        :token => event.token
      )
    end

    def handle_user_password_updated!(event)
      deliver_updated_password_email(
        :user => event.object, 
        :from => site(event.source.site).email_from
      )
    end

    private

      def password_reset_link(controller, token)
        controller.send(:url_for, :action => 'edit', :token => token)
      end
  end
  
  def reset_password_email(attributes = {})
    recipients attributes[:user].email
    from       attributes[:from]
    subject    I18n.t(:'adva.passwords.notifications.reset_password.subject')
    body       attributes
  end

  def updated_password_email(attributes = {})
    recipients attributes[:user].email
    from       attributes[:from]
    subject    I18n.t(:'adva.passwords.notifications.password_updated.subject')
    body       attributes
  end
end